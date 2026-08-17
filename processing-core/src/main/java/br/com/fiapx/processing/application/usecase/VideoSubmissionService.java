package br.com.fiapx.processing.application.usecase;

import br.com.fiapx.processing.application.contract.*;
import br.com.fiapx.processing.application.port.in.*;
import br.com.fiapx.processing.application.port.out.*;
import br.com.fiapx.processing.domain.*;
import java.util.List;

public final class VideoSubmissionService implements RegisterVideoSubmission, br.com.fiapx.processing.application.port.in.StoreVideoSubmission, ListProcessingJobs {
    private final ProcessingJobRepository jobs; private final ProcessingJobIdGenerator ids; private final ProcessingJobWorkPublisher work; private final VideoSubmissionStorage videos;
    public VideoSubmissionService(ProcessingJobRepository jobs, ProcessingJobIdGenerator ids, ProcessingJobWorkPublisher work, VideoSubmissionStorage videos) { this.jobs = jobs; this.ids = ids; this.work = work; this.videos = videos; }
    public ProcessingJobView register(SubmitVideoSubmission command) { return accept(command.userId(), command.objectKey()); }
    public ProcessingJobView store(br.com.fiapx.processing.application.contract.StoreVideoSubmission command) {
        var jobId = ids.nextId();
        var objectKey = videos.store(jobId, command.fileName(), command.contentType(), command.contents());
        return accept(jobId, command.userId(), objectKey);
    }
    private ProcessingJobView accept(String userId, String objectKey) { return accept(ids.nextId(), userId, objectKey); }
    private ProcessingJobView accept(String jobId, String userId, String objectKey) { var job = ProcessingJob.accepted(new ProcessingJobId(jobId), new UserId(userId), new VideoSubmissionId(objectKey)); jobs.save(job); work.publishAccepted(new ProcessingJobAccepted(job.id().value(), objectKey)); return view(job); }
    public List<ProcessingJobView> listFor(String userId) { return jobs.findByOwner(userId).stream().map(this::view).toList(); }
    private ProcessingJobView view(ProcessingJob job) { return new ProcessingJobView(job.id().value(), job.status().name(), job.imageArchive().map(ImageArchive::objectKey).orElse(null)); }
}
