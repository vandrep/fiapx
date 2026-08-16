package br.com.fiapx.processing.adapter.out.memory;

import br.com.fiapx.processing.application.port.out.ProcessingJobRepository;
import br.com.fiapx.processing.domain.ProcessingJob;
import jakarta.enterprise.context.ApplicationScoped;
import java.util.*;

@ApplicationScoped
public class InMemoryProcessingJobRepository implements ProcessingJobRepository {
    private final Map<String, ProcessingJob> jobs = new LinkedHashMap<>();
    public synchronized void save(ProcessingJob job) { jobs.put(job.id().value(), job); }
    public synchronized List<ProcessingJob> findByOwner(String userId) { return jobs.values().stream().filter(job -> job.owner().value().equals(userId)).toList(); }
}
