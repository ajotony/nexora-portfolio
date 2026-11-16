import {
  InternalServerErrorException,
  NotFoundException,
} from '@nestjs/common';
import { JobsService } from './jobs.service';
import { JobStatus } from './entities/job.entity';

describe('JobsService', () => {
  const repository = {
    create: jest.fn(),
    save: jest.fn(),
    find: jest.fn(),
    findOneBy: jest.fn(),
    delete: jest.fn(),
  };
  const publisher = { publish: jest.fn() };
  let service: JobsService;

  beforeEach(() => {
    jest.resetAllMocks();
    service = new JobsService(repository as never, publisher as never);
  });

  it('persists a queued job and publishes it', async () => {
    const job = {
      id: 'job-1',
      operation: 'generate_system_report',
      status: JobStatus.QUEUED,
    };
    repository.create.mockReturnValue(job);
    repository.save.mockResolvedValue(job);
    await expect(
      service.create({ operation: 'generate_system_report' }),
    ).resolves.toEqual(job);
    expect(publisher.publish).toHaveBeenCalledWith('job-1');
  });

  it('removes the record when the broker cannot accept it', async () => {
    const job = { id: 'job-1' };
    repository.create.mockReturnValue(job);
    repository.save.mockResolvedValue(job);
    publisher.publish.mockRejectedValue(new Error('offline'));
    await expect(
      service.create({ operation: 'generate_system_report' }),
    ).rejects.toBeInstanceOf(InternalServerErrorException);
    expect(repository.delete).toHaveBeenCalledWith('job-1');
  });

  it('throws for an unknown job', async () => {
    repository.findOneBy.mockResolvedValue(null);
    await expect(service.findOne('missing')).rejects.toBeInstanceOf(
      NotFoundException,
    );
  });
});
