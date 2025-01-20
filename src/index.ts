// Reexport the native module. On web, it will be resolved to ExpoVideoToAudioModule.web.ts
// and on native platforms to ExpoVideoToAudioModule.ts
export { default } from './ExpoVideoToAudioModule';
export * from  './ExpoVideoToAudio.types';
