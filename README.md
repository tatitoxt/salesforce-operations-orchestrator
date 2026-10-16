# Salesforce Operations Orchestrator

Proyecto de práctica con Salesforce DX para modelar tareas operativas, reglas de ejecución y componentes Lightning. Incluye clases Apex, triggers, metadatos de Salesforce y componentes LWC.

## Qué contiene

- Modelo de tareas operativas y reglas configurables mediante Custom Metadata.
- Procesamiento asíncrono con Apex.
- Componentes Lightning para consultar tareas y eventos.
- Pruebas Apex y Jest en el repositorio.

## Preparar el entorno

Necesitás Salesforce CLI y una scratch org o una Developer Edition. Para desplegar el proyecto:

```bash
git clone https://github.com/tatitoxt/salesforce-operations-orchestrator.git
cd salesforce-operations-orchestrator
sf org login web --alias dev
sf project deploy start --target-org dev
```

Para ejecutar las pruebas:

```bash
sf apex run test --result-format human --target-org dev
npm install
npm run test:unit
```

El proyecto está pensado como muestra técnica y requiere una org Salesforce para probarse. No se publica una cifra de cobertura porque el resultado depende de la org y de la ejecución actual.

## Licencia

MIT. Ver [LICENSE.txt](LICENSE.txt).
