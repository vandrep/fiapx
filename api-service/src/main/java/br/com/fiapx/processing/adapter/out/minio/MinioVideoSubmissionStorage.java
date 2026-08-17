package br.com.fiapx.processing.adapter.out.minio;

import br.com.fiapx.processing.application.port.out.VideoSubmissionStorage;
import io.minio.BucketExistsArgs;
import io.minio.MakeBucketArgs;
import io.minio.MinioClient;
import io.minio.PutObjectArgs;
import jakarta.enterprise.context.ApplicationScoped;
import org.eclipse.microprofile.config.inject.ConfigProperty;
import java.io.ByteArrayInputStream;

@ApplicationScoped
public class MinioVideoSubmissionStorage implements VideoSubmissionStorage {
    private static final String BUCKET = "video-submissions";
    private final MinioClient client;

    public MinioVideoSubmissionStorage(@ConfigProperty(name = "fiapx.minio.url") String url,
                                       @ConfigProperty(name = "fiapx.minio.access-key") String accessKey,
                                       @ConfigProperty(name = "fiapx.minio.secret-key") String secretKey) {
        client = MinioClient.builder().endpoint(url).credentials(accessKey, secretKey).build();
    }

    @Override public String store(String jobId, String fileName, String contentType, byte[] contents) {
        var key = "videos/" + jobId + "/" + fileName.replaceAll("[^A-Za-z0-9._-]", "_");
        try {
            if (!client.bucketExists(BucketExistsArgs.builder().bucket(BUCKET).build())) client.makeBucket(MakeBucketArgs.builder().bucket(BUCKET).build());
            client.putObject(PutObjectArgs.builder().bucket(BUCKET).object(key).contentType(contentType)
                    .stream(new ByteArrayInputStream(contents), contents.length, -1).build());
            return key;
        } catch (Exception exception) { throw new IllegalStateException("Could not store Video Submission", exception); }
    }
}
