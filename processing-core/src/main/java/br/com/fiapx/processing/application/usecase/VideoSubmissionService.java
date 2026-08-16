package br.com.fiapx.processing.application.usecase;

import br.com.fiapx.processing.application.contract.*;
import br.com.fiapx.processing.application.port.in.*;
import br.com.fiapx.processing.application.port.out.*;
import br.com.fiapx.processing.domain.*;
import java.util.List;

public final class VideoSubmissionService implements RegisterVideoSubmission, ListProcessingJobs {
    private final ProcessingJobRepository jobs; private final ProcessingJobIdGenerator ids;
    public VideoSubmissionService(ProcessingJobRepository jobs, ProcessingJobIdGenerator ids) { this.jobs = jobs; this.ids = ids; }
    public ProcessingJobView register(SubmitVideoSubmission command) { var job = ProcessingJob.accepted(new ProcessingJobId(ids.nextId()), new UserId(command.userId()), new VideoSubmissionId(command.objectKey())); jobs.save(job); return view(job); }
    public List<ProcessingJobView> listFor(String userId) { return jobs.findByOwner(userId).stream().map(this::view).toList(); }
    private ProcessingJobView view(ProcessingJob job) { return new ProcessingJobView(job.id().value(), job.status().name(), job.imageArchive().map(ImageArchive::objectKey).orElse(null)); }
}
