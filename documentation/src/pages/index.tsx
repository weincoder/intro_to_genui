import type {ReactNode} from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import HomepageFeatures from '@site/src/components/HomepageFeatures';
import Heading from '@theme/Heading';
import Translate from '@docusaurus/Translate';

import styles from './index.module.css';

function HomepageHeader() {
  return (
    <header className={clsx('hero hero--primary', styles.heroBanner)}>
      <div className="container">
        <Heading as="h1" className="hero__title">
          <Translate id="homepage.title">Intro to GenUI & A2UI</Translate>
        </Heading>
        <p className="hero__subtitle">
          <Translate id="homepage.tagline">
            Aprende a construir interfaces dinámicas y conversacionales con Flutter, Gemini y el protocolo Agent-to-UI.
          </Translate>
        </p>
        <div className={styles.buttons}>
          <Link
            className="button button--secondary button--lg"
            to="/docs/intro/welcome">
            <Translate id="homepage.cta.button">Comenzar Guía de Implementación 🚀</Translate>
          </Link>
          <Link
            className="button button--outline button--secondary button--lg"
            style={{marginLeft: '12px'}}
            href="https://github.com/weincoder/intro_to_genui">
            GitHub
          </Link>
        </div>
      </div>
    </header>
  );
}

export default function Home(): ReactNode {
  const {siteConfig} = useDocusaurusContext();
  return (
    <Layout
      title={siteConfig.title}
      description="Documentación y guía de arquitectura para implementar Agent-to-UI (A2UI) en Flutter con Gemini y GenUI">
      <HomepageHeader />
      <main>
        <HomepageFeatures />
      </main>
    </Layout>
  );
}
