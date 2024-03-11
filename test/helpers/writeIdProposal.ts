import * as fs from 'fs/promises';

const proposalFile = __dirname + '/proposals.json';

export const writeIdProposal = async ({
  id,
  proposal,
}: {
  id: number;
  proposal: string;
}) => {
  try {
    const fileContent = await fs.readFile(proposalFile, 'utf-8');
    const proposals = JSON.parse(fileContent);
    proposals[proposal] = id;

    const updatedContent = JSON.stringify(proposals, null, 2);

    await fs.writeFile(proposalFile, updatedContent);
  } catch (error) {
    console.error(`Error writing proposal to file: ${error}`);
  }
};

export const readIdFromProposal = async (
  proposal: string,
): Promise<number | null> => {
  try {
    const fileContent = await fs.readFile(proposalFile, 'utf-8');
    const proposals = JSON.parse(fileContent);
    const id = proposals[proposal];

    return id !== undefined ? id : 0;
  } catch (error) {
    console.error(`Error reading file: ${error}`);
    return 0;
  }
};

