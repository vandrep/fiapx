package br.com.fiapx.processing.application.port.out;

public interface VideoSubmissionStorage {
    String store(String processingJobId, String fileName, String contentType, byte[] contents);
}
