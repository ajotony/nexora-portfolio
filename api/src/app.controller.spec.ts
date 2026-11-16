import { AppController } from './app.controller';
import { AppService } from './app.service';

describe('AppController', () => {
  let appController: AppController;

  beforeEach(() => {
    const appService = new AppService();
    appController = new AppController(appService);
  });

  describe('root', () => {
    it('should return API identity', () => {
      expect(appController.getHello()).toEqual({
        service: 'nexora-api',
        status: 'ok',
      });
    });
  });

  describe('health', () => {
    it('should return API health status', () => {
      const health = appController.getHealth();

      expect(health.status).toBe('ok');
      expect(health.service).toBe('nexora-api');
      expect(typeof health.environment).toBe('string');
    });
  });
});
