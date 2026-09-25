import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'Intro to GenUI & A2UI',
  tagline: 'Guía práctica para implementar Agent-to-UI (A2UI) en Flutter con Gemini y GenUI',
  favicon: 'img/favicon.ico',

  future: {
    v4: true,
  },

  url: 'https://weincoder.github.io',
  baseUrl: '/intro_to_genui/',

  organizationName: 'weincoder',
  projectName: 'intro_to_genui',
  trailingSlash: false,

  onBrokenLinks: 'throw',

  i18n: {
    defaultLocale: 'es',
    locales: ['es', 'en'],
    localeConfigs: {
      es: {
        label: 'Español',
        direction: 'ltr',
        htmlLang: 'es-ES',
      },
      en: {
        label: 'English',
        direction: 'ltr',
        htmlLang: 'en-US',
      },
    },
  },

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          routeBasePath: 'docs',
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    image: 'img/docusaurus-social-card.jpg',
    colorMode: {
      respectPrefersColorScheme: true,
      defaultMode: 'dark',
    },
    navbar: {
      title: 'Intro to GenUI & A2UI',
      logo: {
        alt: 'GenUI Flutter Logo',
        src: 'img/logo.svg',
      },
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'docsSidebar',
          position: 'left',
          label: 'Documentación',
        },
        {
          type: 'localeDropdown',
          position: 'right',
        },
        {
          href: 'https://github.com/weincoder/intro_to_genui',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Documentación',
          items: [
            {
              label: 'Introducción a A2UI',
              to: '/docs/intro/welcome',
            },
            {
              label: 'Arquitectura',
              to: '/docs/architecture/overview',
            },
            {
              label: 'Paso a Paso',
              to: '/docs/implementation-guide/setup-and-dependencies',
            },
          ],
        },
        {
          title: 'Comunidad & Autor',
          items: [
            {
              label: 'YouTube (Weincode)',
              href: 'https://youtube.com/@weincode',
            },
            {
              label: 'LinkedIn (Daniel Herrera)',
              href: 'https://www.linkedin.com/in/daniel-herrera-sanchez-a4106a56/',
            },
            {
              label: 'Flutter Medellín',
              href: 'https://github.com/weincoder/intro_to_genui',
            },
          ],
        },
        {
          title: 'Recursos',
          items: [
            {
              label: 'Repositorio GitHub',
              href: 'https://github.com/weincoder/intro_to_genui',
            },
            {
              label: 'Package genui (pub.dev)',
              href: 'https://pub.dev/packages/genui',
            },
            {
              label: 'Firebase Vertex AI',
              href: 'https://cloud.google.com/vertex-ai',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Intro to GenUI - Daniel Herrera (Weincode). Construido con Docusaurus.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
      additionalLanguages: ['dart', 'bash', 'json', 'yaml'],
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
