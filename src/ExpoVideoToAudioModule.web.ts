import { registerWebModule, NativeModule } from 'expo';

import { ExpoVideoToAudioModuleEvents } from './ExpoVideoToAudio.types';

class ExpoVideoToAudioModule extends NativeModule<ExpoVideoToAudioModuleEvents> {
  PI = Math.PI;
  async setValueAsync(value: string): Promise<void> {
    this.emit('onChange', { value });
  }
  hello() {
    return 'Hello world! 👋';
  }
}

export default registerWebModule(ExpoVideoToAudioModule);
