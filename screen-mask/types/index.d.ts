export type Curtain = boolean

declare module 'claude-code' {
  interface PluginState {
    'screen-mask': { isCurtain: Curtain }
  }
}
