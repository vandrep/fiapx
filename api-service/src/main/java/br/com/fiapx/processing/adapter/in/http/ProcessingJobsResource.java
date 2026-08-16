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

@Path("/processing-jobs") @Authenticated @Produces(MediaType.APPLICATION_JSON)
public class ProcessingJobsResource {
    @Inject RegisterVideoSubmission register;
    @Inject ListProcessingJobs list;
    @Inject SecurityIdentity identity;
    @POST @Consumes(MediaType.MULTIPART_FORM_DATA)
    public Response submit(@RestForm("video") FileUpload video) {
        if (video == null || video.fileName() == null) throw new BadRequestException("video is required");
        var job = register.register(new SubmitVideoSubmission(identity.getPrincipal().getName(), "videos/" + video.fileName()));
        return Response.accepted(job).location(UriBuilder.fromPath("/processing-jobs/{id}").build(job.id())).build();
    }
    @GET public List<ProcessingJobView> list() { return list.listFor(identity.getPrincipal().getName()); }
}
