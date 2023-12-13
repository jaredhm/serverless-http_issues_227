import type { GetServerSideProps, NextPage } from "next";
import Link from "next/link";
import pino from 'pino';
import { faker } from '@faker-js/faker';

type Props = {
  name: string,
  otherNames: Array<string>
};
type WithLambdaContext = {
  context: {
    awsRequestId: string;
  };
};

const baseLogger = pino({ level: 'debug' });

const hasLambdaContext = (req: unknown): req is WithLambdaContext => {
  return Boolean(typeof req === "object" && req && "context" in req);
};

export const getServerSideProps: GetServerSideProps<Props> = async (
  ctx
) => {
  const { req, query } = ctx;
  const logger = baseLogger.child({
    url: req.url,
    method: req.method,
    awsRequestId: hasLambdaContext(req) ? req.context.awsRequestId : null,
  });

  logger.debug("pages/index::getServerSideProps");

  const namePromise = new Promise<string>((resolve) => {
    let name: string;
    if (typeof query.name === 'string') {
      name = query.name;
    } else {
      name = 'stranger'
    }
    setTimeout(
      () => resolve(name),
      500
    );
  });

  return {
    props: { 
      name: await namePromise,
      otherNames: new Array(10)
        .fill(0)
        .map(() => faker.name.firstName().toLocaleLowerCase())
    }
  };
};

const HelloPage: NextPage<Props> = ({ name, otherNames }) => {
  return (
    <div>
      <h1>Hello {name}!</h1>
      <hr/>
      <p>Other suitable names:</p>
      <ul>
        {
          otherNames.map((o) => {
            return (
              <li key={o}>
                <Link href={`/hello/${o}`}>
                  {o}
                </Link>
              </li>
            )
          })
        }
      </ul>
    </div>
  );
};

export default HelloPage;
