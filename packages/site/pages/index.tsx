import { NextPage } from 'next';
import Link from 'next/link';

const Home: NextPage<{}> = () => {
  return (
    <div>
      <Link href="/hello">
        Click me!
      </Link>
    </div>
  )
};

export default Home;