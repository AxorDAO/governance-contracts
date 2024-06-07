import { JsonFragment } from '@ethersproject/abi';
import { Contract, Signer } from 'ethers';
import { Interface } from 'ethers/lib/utils';

import {
  InitializableAdminUpgradeabilityProxy__factory,
  ProxyAdmin,
  ProxyAdmin__factory,
} from '../../../types';
import { waitForTx } from '../../lib/util';

// Generic type for typechain contract factories. Different from ethers ContractFactory.
type TypechainContractFactoryClass<T, U extends unknown[]> = {
  new (signer: Signer | undefined): TypechainContractFactory<T, U>;
  abi: JsonFragment[];
};
type TypechainContractFactory<T, U extends unknown[]> = {
  attach(address: string): T;
  deploy(...args: U): Promise<T>;
};

export async function deployUpgradeable<
  T extends Contract,
  U extends unknown[],
>(
  factory: TypechainContractFactoryClass<T, U>,
  deployer: Signer,
  constructorArgs: U,
  initializeArgs: {}[],
): Promise<[T, T, ProxyAdmin]> {
  console.log('start deploy');

  const proxyAdmin = await new ProxyAdmin__factory(deployer).deploy();
  const proxy = await new InitializableAdminUpgradeabilityProxy__factory(
    deployer,
  ).deploy();
  const implementation = await new factory(deployer).deploy(...constructorArgs);

  console.log('Await deploy impl, admin, proxy');
  // await Promise.all([
  await waitForTx(proxyAdmin.deployTransaction);
  await waitForTx(proxy.deployTransaction);
  await waitForTx(implementation.deployTransaction);
  // ]);

  console.log('contract created successfully');
  const initializeCalldata = new Interface(factory.abi).encodeFunctionData(
    'initialize',
    initializeArgs,
  );

  console.log('waitting for initialize tx');
  await waitForTx(
    await proxy['initialize(address,address,bytes)'](
      implementation.address,
      proxyAdmin.address,
      initializeCalldata,
    ),
  );

  console.log('contract initialized');

  const proxyInstance = new factory(deployer).attach(proxy.address);
  return [proxyInstance, implementation, proxyAdmin];
}

export async function upgradeContract<T extends Contract, U extends unknown[]>(
  factory: TypechainContractFactoryClass<T, U>,
  deployer: Signer,
  proxyAddress: string,
  proxyAdmin: ProxyAdmin,
  constructorArgs: U,
): Promise<T> {
  const newImplementation = await new factory(deployer).deploy(
    ...constructorArgs,
  );
  await waitForTx(newImplementation.deployTransaction);
  await waitForTx(
    await proxyAdmin.upgrade(proxyAddress, newImplementation.address),
  );
  return newImplementation;
}
