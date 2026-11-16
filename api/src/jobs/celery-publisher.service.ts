import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class CeleryPublisherService {
  constructor(private readonly config: ConfigService) {}

  async publish(jobId: string): Promise<void> {
    const publisherUrl =
      this.config.get<string>('CELERY_PUBLISHER_URL') ??
      'http://celery-publisher:8090';

    const response = await fetch(`${publisherUrl}/publish`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ job_id: jobId }),
    });

    if (!response.ok) {
      const body = await response.text();

      throw new Error(
        `Celery publisher failed: ${response.status} ${body}`,
      );
    }
  }
}