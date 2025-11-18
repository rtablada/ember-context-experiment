import { tracked } from '@glimmer/tracking';

export class AppState {
  @tracked userName;

  constructor() {
    this.userName = 'Guest';
  }
}
