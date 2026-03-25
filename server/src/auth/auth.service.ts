import {
  Injectable,
  ConflictException,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';

const BCRYPT_ROUNDS = 12;

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
}

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
  ) {}

  async register(dto: RegisterDto): Promise<AuthTokens & { user: object }> {
    const exists = await this.prisma.user.findUnique({
      where: { email: dto.email },
    });
    if (exists) {
      throw new ConflictException('该邮箱已被注册');
    }

    const passwordHash = await bcrypt.hash(dto.password, BCRYPT_ROUNDS);
    const user = await this.prisma.user.create({
      data: {
        email: dto.email,
        passwordHash,
        displayName: dto.displayName,
      },
    });

    const tokens = this.signTokens(user.id, user.email);
    return {
      ...tokens,
      user: { id: user.id, email: user.email, displayName: user.displayName },
    };
  }

  async login(dto: LoginDto): Promise<AuthTokens & { user: object }> {
    const user = await this.prisma.user.findUnique({
      where: { email: dto.email },
    });
    if (!user) {
      throw new UnauthorizedException('邮箱或密码错误');
    }

    const isMatch = await bcrypt.compare(dto.password, user.passwordHash);
    if (!isMatch) {
      throw new UnauthorizedException('邮箱或密码错误');
    }

    const tokens = this.signTokens(user.id, user.email);
    return {
      ...tokens,
      user: { id: user.id, email: user.email, displayName: user.displayName },
    };
  }

  refresh(refreshToken: string): AuthTokens {
    try {
      const payload = this.jwt.verify<{ sub: string; email: string }>(
        refreshToken,
        { secret: process.env.JWT_REFRESH_SECRET },
      );
      return this.signTokens(payload.sub, payload.email);
    } catch {
      throw new UnauthorizedException('refreshToken 无效或已过期');
    }
  }

  private signTokens(userId: string, email: string): AuthTokens {
    const payload = { sub: userId, email };
    return {
      accessToken: this.jwt.sign(payload, {
        secret: process.env.JWT_ACCESS_SECRET,
        expiresIn: (process.env.JWT_ACCESS_EXPIRES ?? '15m') as any,
      }),
      refreshToken: this.jwt.sign(payload, {
        secret: process.env.JWT_REFRESH_SECRET,
        expiresIn: (process.env.JWT_REFRESH_EXPIRES ?? '30d') as any,
      }),
    };
  }
}
