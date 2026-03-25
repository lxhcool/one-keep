import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
  Logger,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';
import { FastifyRequest } from 'fastify';
import { JwtPayload } from '../decorators/current-user.decorator';

@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  private readonly logger = new Logger('HTTP');

  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const req = context.switchToHttp().getRequest<
      FastifyRequest & { user?: JwtPayload }
    >();
    const { method, url, user } = req;
    const start = Date.now();

    return next.handle().pipe(
      tap({
        next: () => {
          const res = context.switchToHttp().getResponse<{ statusCode: number }>();
          this.logger.log(
            `${method} ${url} ${res.statusCode} ${Date.now() - start}ms` +
              (user ? ` userId=${user.sub}` : ''),
          );
        },
        error: () => {
          this.logger.warn(
            `${method} ${url} ERR ${Date.now() - start}ms`,
          );
        },
      }),
    );
  }
}
