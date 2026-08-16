package br.com.fiapx.processing.domain;

import java.util.Objects;

public record ImageArchive(String objectKey, int frameCount) {
    public ImageArchive { Objects.requireNonNull(objectKey); if (frameCount < 1) throw new IllegalArgumentException("frameCount must be positive"); }
}
