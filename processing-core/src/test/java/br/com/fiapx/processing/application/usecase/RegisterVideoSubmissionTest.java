package br.com.fiapx.processing.application.usecase;

import static org.junit.jupiter.api.Assertions.assertEquals;
import java.util.List;
import org.junit.jupiter.api.Test;
import br.com.fiapx.processing.application.contract.SubmitVideoSubmission;
import br.com.fiapx.processing.application.port.out.ProcessingJobRepository;
import br.com.fiapx.processing.application.port.out.ProcessingJobIdGenerator;
import br.com.fiapx.processing.application.port.out.ProcessingJobWorkPublisher;
import br.com.fiapx.processing.domain.ProcessingJob;

class RegisterVideoSubmissionTest {
    @Test void registers_a_job_with_the_id_supplied_by_its_port_and_lists_only_its_owner() {
        var jobs = new CapturingRepository();
        var work = new CapturingWorkPublisher();
        var service = new VideoSubmissionService(jobs, () -> "job-42", work, (id, file, contentType, bytes) -> "videos/" + id + ".mp4");

        var accepted = service.register(new SubmitVideoSubmission("ana", "videos/a.mp4"));

        assertEquals("job-42", accepted.id());
        assertEquals(1, service.listFor("ana").size());
        assertEquals(List.of(), service.listFor("bruno"));
        assertEquals("job-42", work.publishedJobId);
    }
    private static final class CapturingWorkPublisher implements ProcessingJobWorkPublisher {
        private String publishedJobId;
        public void publishAccepted(br.com.fiapx.processing.application.contract.ProcessingJobAccepted accepted) { publishedJobId = accepted.processingJobId(); }
    }
    private static final class CapturingRepository implements ProcessingJobRepository {
        private final java.util.Map<String, ProcessingJob> jobs = new java.util.LinkedHashMap<>();
        public void save(ProcessingJob job) { jobs.put(job.id().value(), job); }
        public List<ProcessingJob> findByOwner(String userId) { return jobs.values().stream().filter(j -> j.owner().value().equals(userId)).toList(); }
    }
}
