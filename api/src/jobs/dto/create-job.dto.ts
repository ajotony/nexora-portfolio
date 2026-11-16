import { IsIn } from 'class-validator';

export const SUPPORTED_OPERATIONS = ['generate_system_report'] as const;
export type SupportedOperation = (typeof SUPPORTED_OPERATIONS)[number];

export class CreateJobDto {
  @IsIn(SUPPORTED_OPERATIONS)
  operation: SupportedOperation;
}
