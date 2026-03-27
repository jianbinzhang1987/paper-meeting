package cn.iocoder.yudao.module.meeting.service.meeting;

import cn.iocoder.yudao.module.infra.api.file.FileApi;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingSignatureDO;
import cn.iocoder.yudao.module.meeting.dal.mysql.meeting.MeetingSignatureMapper;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.validation.annotation.Validated;

import java.time.LocalDateTime;

@Service
@Validated
public class MeetingSignatureServiceImpl implements MeetingSignatureService {

    @Resource
    private FileApi fileApi;
    @Resource
    private MeetingSignatureMapper meetingSignatureMapper;

    @Override
    public MeetingSignatureDO submitSignature(Long meetingId, Long userId, String seatId, byte[] imageContent, Integer strokeCount) {
        String url = fileApi.createFile(
                imageContent,
                "signature-" + meetingId + "-" + userId + "-" + System.currentTimeMillis() + ".png",
                "meeting/signature",
                "image/png"
        );
        MeetingSignatureDO signature = new MeetingSignatureDO();
        signature.setMeetingId(meetingId);
        signature.setUserId(userId);
        signature.setSeatId(seatId);
        signature.setFileUrl(url);
        signature.setStrokeCount(strokeCount);
        signature.setSubmitTime(LocalDateTime.now());
        meetingSignatureMapper.insert(signature);
        return signature;
    }

    @Override
    public MeetingSignatureDO getLatestSignature(Long meetingId, Long userId) {
        return meetingSignatureMapper.selectLatest(meetingId, userId);
    }
}
