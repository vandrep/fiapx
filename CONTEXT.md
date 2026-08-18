# FIAP X Video Processing

This context receives videos from authenticated users and manages their asynchronous conversion into downloadable image archives.

## Language

**Video Submission**:
A video supplied by one User for conversion. Its lifecycle is tracked independently from the binary object that carries it.
_Avoid_: Upload, request

**Processing Job**:
The asynchronous work item created for a Video Submission, with a status visible to its owning User.
_Avoid_: Task, queue item

**Image Archive**:
The ZIP file containing the frames extracted from a successfully processed Video Submission.
_Avoid_: Output, result file

**User**:
The authenticated person who owns Video Submissions and may access only their own Processing Jobs and Image Archives.
_Avoid_: Account, client
