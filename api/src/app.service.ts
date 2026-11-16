import { Injectable } from '@nestjs/common';

export interface HealthResponse {
  status: 'ok';
  service: string;
  environment: string;
}

@Injectable()
export class AppService {
  getHello(): { service: string; status: string } {
    return { service: 'nexora-api', status: 'ok' };
  }

  getHealth(): HealthResponse {
    return {
      status: 'ok',
      service: 'nexora-api',
      environment:
        process.env.ENVIRONMENT ?? process.env.NODE_ENV ?? 'development',
    };
  }
}
