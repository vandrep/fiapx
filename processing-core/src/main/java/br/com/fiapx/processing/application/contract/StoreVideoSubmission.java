package br.com.fiapx.processing.application.contract;

import java.util.Arrays;
import java.util.Objects;

/** Binary data received at the application boundary; it has no transport dependency. */
public record StoreVideoSubmission(String userId, String fileName, String contentType, byte[] contents) {
    public StoreVideoSubmission {
        Objects.requireNonNull(userId);
        Objects.requireNonNull(fileName);
        Objects.requireNonNull(contentType);
        Objects.requireNonNull(contents);
        contents = Arrays.copyOf(contents, contents.length);
        if (contents.length == 0) throw new IllegalArgumentException("video contents are required");
    }

    @Override public byte[] contents() { return Arrays.copyOf(contents, contents.length); }
}
