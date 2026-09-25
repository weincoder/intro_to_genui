import type {ReactNode} from 'react';
import clsx from 'clsx';
import Heading from '@theme/Heading';
import Translate from '@docusaurus/Translate';
import styles from './styles.module.css';

type FeatureItem = {
  title: ReactNode;
  icon: string;
  description: ReactNode;
};

const FeatureList: FeatureItem[] = [
  {
    title: <Translate id="feature.a2ui.title">Protocolo A2UI & GenUI</Translate>,
    icon: '🤖 ➔ 📱',
    description: (
      <Translate id="feature.a2ui.desc">
        Permite que el modelo de IA (Gemini 2.5) decida cuándo y cómo renderizar widgets nativos interactivos de Flutter mediante esquemas JSON declarativos y catálogos de superficies.
      </Translate>
    ),
  },
  {
    title: <Translate id="feature.architecture.title">Arquitectura Limpia y Modular</Translate>,
    icon: '🏛️ ➔ ⚙️',
    description: (
      <Translate id="feature.architecture.desc">
        Separación estricta en 4 capas: Domain (Dart puro), Infrastructure (adapters y mappers defensivos), Config (providers y prompts) y UI (widgets y custom painters).
      </Translate>
    ),
  },
  {
    title: <Translate id="feature.events.title">Interactividad Bidireccional</Translate>,
    icon: '⏱️ ➔ 🔄',
    description: (
      <Translate id="feature.events.desc">
        La interfaz no es solo pasiva: temporizadores y acciones del usuario disparan UserActionEvents que regresan al agente como turnos conversacionales nativos.
      </Translate>
    ),
  },
];

function Feature({title, icon, description}: FeatureItem) {
  return (
    <div className={clsx('col col--4')}>
      <div className="text--center" style={{fontSize: '3.5rem', marginBottom: '1rem'}}>
        <span>{icon}</span>
      </div>
      <div className="text--center padding-horiz--md">
        <Heading as="h3">{title}</Heading>
        <p>{description}</p>
      </div>
    </div>
  );
}

export default function HomepageFeatures(): ReactNode {
  return (
    <section className={styles.features} style={{padding: '3rem 0'}}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
