import { Controller, Get } from '@nestjs/common';
import { AppService } from './app.service';
import type { HealthResponse } from './app.service';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  getHello(): { service: string; status: string } {
    return this.appService.getHello();
  }

  @Get('health')
  getHealth(): HealthResponse {
    return this.appService.getHealth();
  }

  @Get('health/live')
  getLiveness(): HealthResponse {
    return this.appService.getHealth();
  }

  @Get('health/ready')
  getReadiness(): HealthResponse {
    return this.appService.getHealth();
  }
}
