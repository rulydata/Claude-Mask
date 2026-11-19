import type { Register, ThemeSetArgs } from 'claude-code'

import { makeColors } from './make-colors.js'

// Tampilan aplikasi chat gelap: latar hijau-kebiruan tua, balon pesan,
// pola doodle tipis. Desain sendiri, tanpa logo/merek aplikasi mana pun.
const { theme, problems } = makeColors({
  label: 'Chat Night',
  only: 'dark',
  roles: { accent: '#2fbf8f', danger: '#e0675c', success: '#3fbf7a', warning: '#d9a53a', pro: '#8f8fe0' },
  dark: {
    gray: {
      anchors: {
        'surface-0': '#0e171b',
        'surface-1': '#152126',
        'surface-2': '#1b2a30',
        'surface-3': '#1f2f36',
        'text-primary': '#e8eef0',
        'text-secondary': '#c2ccd0',
        'text-muted': '#9aa8ae',
      },
    },
  },
})

const OUT_BUBBLE = '#18564a'
const IN_BUBBLE = '#1e2c33'
const NAME_COLOR = '#53d3a6'
const TICK_COLOR = '#5fb8e8'

// Pola doodle buatan sendiri: hati, bintang, awan, balon kecil, titik.
const SCENE = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1600 1000" preserveAspectRatio="xMidYMid slice">
<defs><pattern id="d" width="160" height="160" patternUnits="userSpaceOnUse">
<g fill="none" stroke="#1f2e34" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
<path d="M30 40c-6-8-20-2-14 8l14 12 14-12c6-10-8-16-14-8z"/>
<path d="M110 25l5 11 12 1-9 8 3 12-11-6-11 6 3-12-9-8 12-1z"/>
<path d="M20 120h30a10 10 0 0 0 0-20 14 14 0 0 0-27-2 9 9 0 0 0-3 22z"/>
<path d="M95 95h40a6 6 0 0 1 6 6v20a6 6 0 0 1-6 6h-26l-10 9v-9h-4a6 6 0 0 1-6-6v-20a6 6 0 0 1 6-6z"/>
<circle cx="75" cy="70" r="4"/><circle cx="145" cy="150" r="3"/>
<path d="M60 145l8-8m0 8l-8-8"/>
</g></pattern></defs>
<rect width="1600" height="1000" fill="#0e171b"/>
<rect width="1600" height="1000" fill="url(#d)"/>
</svg>`

const LOOK: ThemeSetArgs = { colors: theme, backdrop: { scene: 'doodle', glass: false } }

const TYPING: Record<string, string> = {
  requesting: 'mengetik',
  thinking: 'mengetik',
  'tool-input': 'mengetik',
  'tool-use': 'mengirim dokumen',
  responding: 'mengetik',
}

type Store = { store: { get: (k: string) => Promise<unknown> } }

async function isMasked($: Store) {
  return (await $.store.get('isMasked')) !== false
}

async function contactName($: Store) {
  const name = await $.store.get('contact')
  return typeof name === 'string' && name !== '' ? name : 'Rina'
}

const DRAWS = (surface: string) => surface === 'desktop' || surface === 'mobile'

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    await $.command.register({
      name: 'mask',
      description: 'Penyamaran: /mask (on/off), /mask nama <nama kontak>',
    })
    if (await isMasked($)) {
      const unpainted = problems.find(line => line.startsWith("Desktop won't paint"))
      if (unpainted !== undefined) {
        $.ui.toast(unpainted)
      }
      await $.theme.set(LOOK)
    }

    return next(e)
  })

  on('command.run', { command: 'mask' }, async ($, e) => {
    const args = e.args.trim()
    if (args.toLowerCase().startsWith('nama ')) {
      const name = args.slice(5).trim()
      await $.store.set('contact', name)
      return { text: `Nama kontak: ${name}` }
    }
    const now = !(await isMasked($))
    await $.store.set('isMasked', now)
    if (now) {
      await $.theme.set(LOOK)
      return { text: 'Mask: ON' }
    }
    await $.theme.clear()
    return { text: 'Mask: OFF' }
  })

  on('ui.render', { component: 'Backdrop' }, async ($, e, next) => {
    if ((e.surface !== 'desktop' && e.surface !== 'mobile') || !(await isMasked($))) {
      return next(e)
    }
    const { Svg } = $.ui.resolve(e)
    return <Svg source={SCENE} alt="Pola doodle tipis" />
  })

  // Pesan saya: balon hijau di kanan dengan centang dua.
  on('ui.render', { component: 'UserMessage' }, async ($, e, next) => {
    if (!DRAWS(e.surface) || e.props.origin.kind !== 'composer' || !(await isMasked($))) {
      return next(e)
    }
    const { Box, Text } = $.ui.resolve(e)
    return (
      <Box flexDirection="row" justifyContent="flex-end">
        <Box flexDirection="column" alignItems="flex-end" backgroundColor={OUT_BUBBLE} paddingX="md" paddingY="sm">
          <Text>{e.props.text}</Text>
          <Text size="caption" color={TICK_COLOR}>✓✓</Text>
        </Box>
      </Box>
    )
  })

  // Balasan: balon gelap di kiri, nama kontak di blok pertama.
  on('ui.render', { component: 'AssistantMessage' }, async ($, e, next) => {
    if (!DRAWS(e.surface) || !(await isMasked($))) {
      return next(e)
    }
    const { Box, Text } = $.ui.resolve(e)
    const name = await contactName($)
    return (
      <Box flexDirection="row" justifyContent="flex-start">
        <Box flexDirection="column" backgroundColor={IN_BUBBLE} paddingX="md" paddingY="sm">
          {e.props.isFirstOfReply && (
            <Text size="footnote" weight="semibold" color={NAME_COLOR}>{name}</Text>
          )}
          {await next(e)}
        </Box>
      </Box>
    )
  })

  // Baris alat (Bash, Read, dll.) disamarkan jadi lampiran dokumen.
  on('ui.render', { component: 'ToolUse' }, async ($, e, next) => {
    if (!DRAWS(e.surface) || !(await isMasked($))) {
      return next(e)
    }
    const { Text } = $.ui.resolve(e)
    return <Text dimColor size="footnote">📄 Dokumen</Text>
  })

  on('ui.render', { component: 'Spinner' }, async ($, e, next) => {
    if (!(await isMasked($))) {
      return next(e)
    }
    return next({ ...e, props: { ...e.props, word: TYPING[e.props.mode] ?? 'mengetik' } })
  })
}
