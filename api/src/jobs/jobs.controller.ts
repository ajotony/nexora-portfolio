import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Post,
} from '@nestjs/common';
import { CreateJobDto } from './dto/create-job.dto';
import { Job } from './entities/job.entity';
import { JobsService } from './jobs.service';

@Controller('jobs')
export class JobsController {
  constructor(private readonly jobs: JobsService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  create(@Body() dto: CreateJobDto): Promise<Job> {
    return this.jobs.create(dto);
  }

  @Get()
  findAll(): Promise<Job[]> {
    return this.jobs.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string): Promise<Job> {
    return this.jobs.findOne(id);
  }
}
