import { Controller, Get } from '@nestjs/common';
import { UsersService } from './users.service';
import { CurrentUser, JwtPayload } from '../common/decorators/current-user.decorator';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('me')
  getMe(@CurrentUser() user: JwtPayload) {
    return this.usersService.getProfile(user.sub);
  }
}
