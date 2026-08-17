package br.com.fiapx.processing.adapter.in.http;

import br.com.fiapx.processing.application.contract.*;
import br.com.fiapx.processing.application.port.in.*;
import io.quarkus.security.Authenticated;
import io.quarkus.security.identity.SecurityIdentity;
import jakarta.inject.Inject;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.*;
import org.jboss.resteasy.reactive.RestForm;
import org.jboss.resteasy.reactive.multipart.FileUpload;
import java.util.List;
import java.nio.file.Files;

@Path("/processing-jobs") @Authenticated @Produces(MediaType.APPLICATION_JSON)
public class ProcessingJobsResource {
    @Inject br.com.fiapx.processing.application.port.in.StoreVideoSubmission store;
    @Inject ListProcessingJobs list;
    @Inject SecurityIdentity identity;
    @POST @Consumes(MediaType.MULTIPART_FORM_DATA)
    public Response submit(@RestForm("video") FileUpload video) {
        if (video == null || video.fileName() == null) throw new BadRequestException("video is required");
        try {
            var contents = Files.readAllBytes(video.uploadedFile());
            var job = store.store(new br.com.fiapx.processing.application.contract.StoreVideoSubmission(identity.getPrincipal().getName(), video.fileName(), video.contentType(), contents));
            return Response.accepted(job).location(UriBuilder.fromPath("/processing-jobs/{id}").build(job.id())).build();
        } catch (java.io.IOException exception) { throw new BadRequestException("video cannot be read", exception); }
    }
    @GET public List<ProcessingJobView> list() { return list.listFor(identity.getPrincipal().getName()); }
}
