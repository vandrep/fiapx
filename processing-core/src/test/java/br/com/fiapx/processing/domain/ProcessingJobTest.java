package br.com.fiapx.processing.domain;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

import org.junit.jupiter.api.Test;

class ProcessingJobTest {
    @Test void accepts_a_video_submission_then_completes_with_an_image_archive() {
        var job = ProcessingJob.accepted(new ProcessingJobId("job-1"), new UserId("ana"), new VideoSubmissionId("video-1"));

        job.start();
        job.complete(new ImageArchive("archives/job-1.zip", 12));

        assertEquals(ProcessingStatus.COMPLETED, job.status());
        assertEquals("archives/job-1.zip", job.imageArchive().orElseThrow().objectKey());
    }

    @Test void cannot_complete_a_job_that_was_not_started() {
        var job = ProcessingJob.accepted(new ProcessingJobId("job-1"), new UserId("ana"), new VideoSubmissionId("video-1"));

        assertThrows(IllegalStateException.class, () -> job.complete(new ImageArchive("archives/job-1.zip", 12)));
    }

    @Test void records_a_retry_then_fails_after_the_third_processing_failure() {
        var job = ProcessingJob.accepted(new ProcessingJobId("job-1"), new UserId("ana"), new VideoSubmissionId("video-1"));

        job.start(); job.failAttempt(); job.start(); job.failAttempt(); job.start(); job.failAttempt();

        assertEquals(ProcessingStatus.FAILED, job.status());
        assertEquals(3, job.attempts());
    }
}
