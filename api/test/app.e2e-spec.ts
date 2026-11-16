import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { App, Response } from 'supertest/types';
import { AppController } from './../src/app.controller';
import { AppService } from './../src/app.service';

describe('AppController (e2e)', () => {
  let app: INestApplication<App>;
  type ServiceResponse = { service: string };
  type HealthResponse = ServiceResponse & { status: string };

  const getResponseBody = (response: Response): unknown =>
    (response as unknown as { body: unknown }).body;

  const isServiceResponse = (body: unknown): body is ServiceResponse =>
    typeof body === 'object' &&
    body !== null &&
    'service' in body &&
    typeof body.service === 'string';

  const isHealthResponse = (body: unknown): body is HealthResponse =>
    isServiceResponse(body) &&
    'status' in body &&
    typeof body.status === 'string';

  beforeEach(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      controllers: [AppController],
      providers: [AppService],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  it('/ (GET)', () => {
    return request(app.getHttpServer())
      .get('/')
      .expect(200)
      .expect((response: Response) => {
        const body = getResponseBody(response);
        expect(isServiceResponse(body)).toBe(true);
        if (!isServiceResponse(body)) {
          throw new Error(
            'Response body does not match the service response schema',
          );
        }
        expect(body.service).toBe('nexora-api');
      });
  });

  it('/health (GET)', () => {
    return request(app.getHttpServer())
      .get('/health')
      .expect(200)
      .expect((response: Response) => {
        const body = getResponseBody(response);
        expect(isHealthResponse(body)).toBe(true);
        if (!isHealthResponse(body)) {
          throw new Error(
            'Response body does not match the health response schema',
          );
        }
        expect(body.status).toBe('ok');
        expect(body.service).toBe('nexora-api');
      });
  });

  afterEach(async () => {
    await app.close();
  });
});
