import type { Register, ThemeSetArgs } from 'claude-code'

import { makeColors } from './make-colors.js'

// Tampilan "Office Notes": abu-abu netral dengan aksen biru kalem,
// tanpa nuansa oranye/krem khas Claude.
const { theme, problems } = makeColors({
  label: 'Office Notes',
  roles: { accent: '#3b5b7a', danger: '#a8423a', success: '#3f7a4c', warning: '#9a7420', pro: '#5a5a8a' },
  light: {
    gray: {
      anchors: {
        'surface-0': '#e9ebee',
        'surface-1': '#f1f3f5',
        'surface-2': '#f8f9fa',
        'text-primary': '#1e2328',
        'text-secondary': '#454c54',
        'text-muted': '#5d646c',
      },
    },
  },
  dark: {
    gray: {
      anchors: {
        'surface-0': '#1b1d20',
        'surface-1': '#222428',
        'surface-2': '#292c30',
        'surface-3': '#2f3236',
        'text-primary': '#e6e8eb',
        'text-secondary': '#c3c7cc',
        'text-muted': '#a2a7ad',
      },
    },
  },
})

const LOOK: ThemeSetArgs = { colors: theme, backdrop: { color: 'surface-0' } }

// Kata-kata netral pengganti kata animasi khas Claude ("Sauteing...", "Baked for 3s").
const WORDS: Record<string, string> = {
  requesting: 'Syncing',
  thinking: 'Processing',
  'tool-input': 'Loading',
  'tool-use': 'Updating',
  responding: 'Saving',
}

const KEY = 'isMasked'

async function isMasked($: { store: { get: (k: string) => Promise<unknown> } }) {
  return (await $.store.get(KEY)) !== false
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    await $.command.register({ name: 'mask', description: 'Nyalakan/matikan penyamaran tampilan' })

    if (await isMasked($)) {
      const unpainted = problems.find(line => line.startsWith("Desktop won't paint"))
      if (unpainted !== undefined) {
        $.ui.toast(unpainted)
      }
      await $.theme.set(LOOK)
    }

    return next(e)
  })

  on('command.run', { command: 'mask' }, async $ => {
    const now = !(await isMasked($))
    await $.store.set(KEY, now)

    if (now) {
      await $.theme.set(LOOK)
      return { text: 'Mask: ON' }
    }
    await $.theme.clear()
    return { text: 'Mask: OFF' }
  })

  on('ui.render', { component: 'Spinner' }, async ($, e, next) => {
    if (!(await isMasked($))) {
      return next(e)
    }
    return next({ ...e, props: { ...e.props, word: WORDS[e.props.mode] ?? 'Working' } })
  })

  on('ui.render', { component: 'TurnDuration' }, async ($, e, next) => {
    if (!(await isMasked($))) {
      return next(e)
    }
    return next({ ...e, props: { ...e.props, word: 'Done' } })
  })

}
