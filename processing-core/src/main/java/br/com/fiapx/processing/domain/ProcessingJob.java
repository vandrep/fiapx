package br.com.fiapx.processing.domain;

import java.util.Optional;

public final class ProcessingJob {
    private final ProcessingJobId id;
    private final UserId owner;
    private final VideoSubmissionId videoSubmission;
    private ProcessingStatus status;
    private int attempts;
    private ImageArchive imageArchive;

    private ProcessingJob(ProcessingJobId id, UserId owner, VideoSubmissionId videoSubmission) {
        this.id = id; this.owner = owner; this.videoSubmission = videoSubmission; this.status = ProcessingStatus.ACCEPTED;
    }
    public static ProcessingJob accepted(ProcessingJobId id, UserId owner, VideoSubmissionId videoSubmission) { return new ProcessingJob(id, owner, videoSubmission); }
    public void start() { if (status != ProcessingStatus.ACCEPTED) throw new IllegalStateException("Only accepted jobs can start"); status = ProcessingStatus.PROCESSING; }
    public void complete(ImageArchive archive) { if (status != ProcessingStatus.PROCESSING) throw new IllegalStateException("Only processing jobs can complete"); imageArchive = archive; status = ProcessingStatus.COMPLETED; }
    public void failAttempt() { if (status != ProcessingStatus.PROCESSING) throw new IllegalStateException("Only processing jobs can fail"); attempts++; status = attempts == 3 ? ProcessingStatus.FAILED : ProcessingStatus.ACCEPTED; }
    public ProcessingStatus status() { return status; }
    public int attempts() { return attempts; }
    public Optional<ImageArchive> imageArchive() { return Optional.ofNullable(imageArchive); }
    public ProcessingJobId id() { return id; }
    public UserId owner() { return owner; }
    public VideoSubmissionId videoSubmission() { return videoSubmission; }
}
