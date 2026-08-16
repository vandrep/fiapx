package br.com.fiapx.processing.application.port.out;

import br.com.fiapx.processing.domain.ProcessingJob;
import java.util.List;

public interface ProcessingJobRepository { void save(ProcessingJob job); List<ProcessingJob> findByOwner(String userId); }
