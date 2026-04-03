package cn.iocoder.yudao.module.meeting.dal.mysql.meeting;

import cn.iocoder.yudao.framework.mybatis.core.mapper.BaseMapperX;
import cn.iocoder.yudao.framework.mybatis.core.query.LambdaQueryWrapperX;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingDocumentMarkDO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface MeetingDocumentMarkMapper extends BaseMapperX<MeetingDocumentMarkDO> {

    default List<MeetingDocumentMarkDO> selectList(Long meetingId, Long userId, Long documentId) {
        return selectList(new LambdaQueryWrapperX<MeetingDocumentMarkDO>()
                .eq(MeetingDocumentMarkDO::getMeetingId, meetingId)
                .eqIfPresent(MeetingDocumentMarkDO::getUserId, userId)
                .eqIfPresent(MeetingDocumentMarkDO::getDocumentId, documentId)
                .orderByDesc(MeetingDocumentMarkDO::getUpdatedAt, MeetingDocumentMarkDO::getId));
    }
}
