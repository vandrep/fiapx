package br.com.fiapx.processing.application.usecase;

import br.com.fiapx.processing.application.contract.*;
import br.com.fiapx.processing.application.port.in.*;
import br.com.fiapx.processing.domain.*;
import java.util.*;

public final class InMemoryVideoSubmissionService implements RegisterVideoSubmission, ListProcessingJobs {
    private final Map<String, ProcessingJob> jobs = new LinkedHashMap<>();
    public ProcessingJobView register(SubmitVideoSubmission command) {
        var id = UUID.randomUUID().toString();
        var job = ProcessingJob.accepted(new ProcessingJobId(id), new UserId(command.userId()), new VideoSubmissionId(command.objectKey()));
        jobs.put(id, job); return view(job);
    }
    public List<ProcessingJobView> listFor(String userId) { return jobs.values().stream().filter(job -> job.owner().value().equals(userId)).map(this::view).toList(); }
    private ProcessingJobView view(ProcessingJob job) { return new ProcessingJobView(job.id().value(), job.status(), job.imageArchive().map(ImageArchive::objectKey).orElse(null)); }
}
