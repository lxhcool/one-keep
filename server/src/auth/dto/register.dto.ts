import { IsEmail, IsString, MaxLength, MinLength } from 'class-validator';

export class RegisterDto {
  @IsEmail({}, { message: '请输入有效的邮箱地址' })
  email!: string;

  @IsString()
  @MinLength(8, { message: '密码至少 8 位' })
  @MaxLength(64)
  password!: string;

  @IsString()
  @MinLength(1)
  @MaxLength(20, { message: '用户名最多 20 个字符' })
  displayName!: string;
}
