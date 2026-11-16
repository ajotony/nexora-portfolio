import {
  Injectable,
  InternalServerErrorException,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CeleryPublisherService } from './celery-publisher.service';
import { CreateJobDto } from './dto/create-job.dto';
import { Job, JobStatus } from './entities/job.entity';

@Injectable()
export class JobsService {
  constructor(
    @InjectRepository(Job) private readonly jobs: Repository<Job>,
    private readonly publisher: CeleryPublisherService,
  ) {}

  async create(dto: CreateJobDto): Promise<Job> {
    const job = await this.jobs.save(
      this.jobs.create({
        operation: dto.operation,
        status: JobStatus.QUEUED,
        result: null,
        workerName: null,
        startedAt: null,
        completedAt: null,
      }),
    );
    try {
      await this.publisher.publish(job.id);
      return job;
    } catch (error) {
      await this.jobs.delete(job.id);
      throw new InternalServerErrorException('Could not queue job', {
        cause: error,
      });
    }
  }

  async findAll(): Promise<Job[]> {
    return this.jobs.find({ order: { createdAt: 'DESC' }, take: 50 });
  }

  async findOne(id: string): Promise<Job> {
    const job = await this.jobs.findOneBy({ id });
    if (!job) throw new NotFoundException(`Job ${id} was not found`);
    return job;
  }
}
