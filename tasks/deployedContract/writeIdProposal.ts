import * as fs from 'fs/promises';

export const writeAddress = async (
  network: string,
  name: string,
  address: string,
) => {
  const fileDir = __dirname + `/${network}.json`;
  
  try {
    const fileContent = await fs.readFile(fileDir, 'utf-8');
    const data = JSON.parse(fileContent);
    data[name] = address;
    const updatedContent = JSON.stringify(data, null, 2);
    await fs.writeFile(fileDir, updatedContent);
  } catch (error) {
    console.error(`Error writing proposal to file: ${error}`);
  }
};

export const readAddress = async (network: string, name: string) => {
  const fileDir = __dirname + `/${network}.json`;

  try {
    const fileContent = await fs.readFile(fileDir, 'utf-8');
    const data = JSON.parse(fileContent);
    return data[name];
  } catch (error) {
    console.error(`Error writing proposal to file: ${error}`);
  }
};
