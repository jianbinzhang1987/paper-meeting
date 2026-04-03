package cn.iocoder.yudao.module.meeting.service.publicfile;

import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.framework.common.util.object.BeanUtils;
import cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo.MeetingPublicFileArchiveReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo.MeetingPublicFileCategoryTreeRespVO;
import cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo.MeetingPublicFileCreateReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo.MeetingPublicFilePageReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo.MeetingPublicFileUpdateReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.publicfile.MeetingPublicFileDO;
import cn.iocoder.yudao.module.meeting.dal.mysql.publicfile.MeetingPublicFileMapper;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.validation.annotation.Validated;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
@Validated
public class MeetingPublicFileServiceImpl implements MeetingPublicFileService {

    @Resource
    private MeetingPublicFileMapper meetingPublicFileMapper;

    @Override
    public Long create(MeetingPublicFileCreateReqVO createReqVO) {
        MeetingPublicFileDO data = BeanUtils.toBean(createReqVO, MeetingPublicFileDO.class);
        if (data.getEnabled() == null) {
            data.setEnabled(true);
        }
        if (data.getSort() == null) {
            data.setSort(0);
        }
        meetingPublicFileMapper.insert(data);
        return data.getId();
    }

    @Override
    public void update(MeetingPublicFileUpdateReqVO updateReqVO) {
        meetingPublicFileMapper.updateById(BeanUtils.toBean(updateReqVO, MeetingPublicFileDO.class));
    }

    @Override
    public void delete(Long id) {
        meetingPublicFileMapper.deleteById(id);
    }

    @Override
    public MeetingPublicFileDO get(Long id) {
        return meetingPublicFileMapper.selectById(id);
    }

    @Override
    public PageResult<MeetingPublicFileDO> getPage(MeetingPublicFilePageReqVO pageReqVO) {
        return meetingPublicFileMapper.selectPage(pageReqVO);
    }

    @Override
    public List<MeetingPublicFileCategoryTreeRespVO> getCategoryTree() {
        List<MeetingPublicFileDO> fileList = meetingPublicFileMapper.selectListForCategoryTree();
        List<MeetingPublicFileCategoryTreeRespVO> root = new ArrayList<>();
        Map<String, MeetingPublicFileCategoryTreeRespVO> nodeMap = new LinkedHashMap<>();
        fileList.stream()
                .map(MeetingPublicFileDO::getCategory)
                .filter(StringUtils::hasText)
                .distinct()
                .forEach(category -> {
                    String[] segments = category.split("/");
                    String currentPath = "";
                    List<MeetingPublicFileCategoryTreeRespVO> children = root;
                    for (String segment : segments) {
                        if (!StringUtils.hasText(segment)) {
                            continue;
                        }
                        currentPath = currentPath.isEmpty() ? segment : currentPath + "/" + segment;
                        MeetingPublicFileCategoryTreeRespVO current = nodeMap.get(currentPath);
                        if (current == null) {
                            current = new MeetingPublicFileCategoryTreeRespVO();
                            current.setLabel(segment);
                            current.setPath(currentPath);
                            current.setCount(0);
                            current.setChildren(new ArrayList<>());
                            nodeMap.put(currentPath, current);
                            children.add(current);
                        }
                        String path = currentPath;
                        current.setCount((int) fileList.stream()
                            .filter(item -> StringUtils.hasText(item.getCategory()) && item.getCategory().startsWith(path))
                                .count());
                        children = current.getChildren();
                    }
                });
        return root;
    }

    @Override
    public Integer archive(MeetingPublicFileArchiveReqVO reqVO) {
        List<MeetingPublicFileDO> candidateList;
        if (reqVO.getFileIds() != null && !reqVO.getFileIds().isEmpty()) {
            candidateList = meetingPublicFileMapper.selectListByIds(reqVO.getFileIds());
        } else {
            int beforeDays = reqVO.getBeforeDays() == null || reqVO.getBeforeDays() <= 0 ? 180 : reqVO.getBeforeDays();
            LocalDateTime beforeTime = LocalDateTime.now().minusDays(beforeDays);
            candidateList = meetingPublicFileMapper.selectListForArchive(beforeTime, reqVO.getSourceCategoryPrefix());
        }
        if (candidateList.isEmpty()) {
            return 0;
        }
        String archiveRoot = StringUtils.hasText(reqVO.getTargetCategoryPrefix()) ? reqVO.getTargetCategoryPrefix() : "归档资料";
        String monthPath = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM"));
        boolean disableAfterArchive = reqVO.getDisableAfterArchive() == null || reqVO.getDisableAfterArchive();
        int archivedCount = 0;
        for (MeetingPublicFileDO item : candidateList) {
            String category = StringUtils.hasText(item.getCategory()) ? item.getCategory() : "未分类";
            if (category.startsWith(archiveRoot + "/")) {
                continue;
            }
            item.setCategory(archiveRoot + "/" + monthPath + "/" + category);
            if (disableAfterArchive) {
                item.setEnabled(false);
            }
            String remark = StringUtils.hasText(item.getRemark()) ? item.getRemark() + "\n" : "";
            item.setRemark(remark + "[ARCHIVED] " + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
            meetingPublicFileMapper.updateById(item);
            archivedCount++;
        }
        return archivedCount;
    }
}
