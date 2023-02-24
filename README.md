# MCParserCLI

A cli tool for Minecraft Bedrock. It only works on MacOS (and only supports M series chip).
```bash
❯  ./mcp -h
OVERVIEW:
A tool to handle data in Minecraft Bedrock's leveldb

USAGE: mcp <subcommand>

OPTIONS:
  --version               Show the version.
  -h, --help              Show help information.

SUBCOMMANDS:
  extract-all             extract all keys and save their data to files
  extract-chunk           extract and save data in a chunk
  extract-key             extract data using a specified key and save to a file
  decode                  decode nbt data
  delete                  delete chunks from leveldb
  inject                  inject data into leveldb

  See 'mcp help <subcommand>' for detailed help.
```

## Extract all keys

```bash
❯  ./mcp extract-all -h
OVERVIEW: extract all keys and save their data to files

Use this subcommand to extract all data from leveldb.

USAGE: mcp extract-all --src <src> --dst <dst> [--dry-run] [--override] [-a] [-c] [-d] [-m] [-v] [-l <l>]

OPTIONS:
  --src <src>             Path of a world directory.
  --dst <dst>             Path where output directory is.
  --dry-run               Dry run command without saving anything
  --override              Override output directory if exists.
  -a                      Extract keys for actorprefix
  -c                      Extract keys for subchunk
  -d                      Extract keys for digp
  -m                      Extract keys for map
  -v                      Extract keys for village
  -l <l>                  Limit output for each directory. (default: 100)
  --version               Show the version.
  -h, --help              Show help information.
```

Extract without saving data by specified keys.
```bash
❯  ./mcp extract-all --dry-run -l 10 -acdmv --src {{path-to-directory-contains-db}} --dst {{path-to-output-directory}}

========== ========== ========== ========== ========== ==========
Extracting data ...)
    from {{path-to-directory-contains-db}}/db
    to {{path-to-output-directory}}

Extracted: (0,1)_data3D
Extracted: (0,1)_chunkVersion
Extracted: (0,1)_subChunkPrefix(-4)
Extracted: (0,1)_finalizedState
Extracted: (0,1)_metaDataHash
Extracted: (0,1)_blendingData
Extracted: (0,1)_actorDigestVersion
Extracted: (0,2)_data3D
Extracted: (0,2)_chunkVersion
Extracted: (0,2)_subChunkPrefix(-4)
Skipped  : (0,2)_finalizedState
Skipped  : (0,2)_metaDataHash
Skipped  : (0,2)_blendingData
Skipped  : (0,2)_actorDigestVersion
Skipped  : (0,-3)_data3D
Skipped  : (0,-3)_chunkVersion
Skipped  : (0,-3)_subChunkPrefix(-4)
Skipped  : (0,-3)_finalizedState
Skipped  : (0,-3)_metaDataHash
Skipped  : (0,-3)_blendingData
Skipped  : (0,-3)_actorDigestVersion
Skipped  : (1,2)_finalizedState
Skipped  : (1,2)_actorDigestVersion
Extracted: AutonomousEntities
Extracted: BiomeData
Extracted: LevelChunkMetaDataDictionary
Extracted: Overworld
Extracted: actorprefix_0x00_00_00_01_00_00_00_02
Extracted: actorprefix_0x00_00_00_01_00_00_00_03
Extracted: actorprefix_0x00_00_00_01_00_00_00_04
Extracted: actorprefix_0x00_00_00_01_00_00_00_05
Extracted: digp_(0,1)
Extracted: digp_(0,2)
Extracted: digp_(0,-3)
Extracted: digp_(1,2)
Extracted: digp_(-1,1)
Extracted: mobevents
Extracted: schedulerWT
Extracted: scoreboard
Extracted: ~local_player
Skipped  : (-1,1)_data3D
Skipped  : (-1,1)_chunkVersion
Skipped  : (-1,1)_subChunkPrefix(-4)
Skipped  : (-1,1)_finalizedState
Skipped  : (-1,1)_metaDataHash
Skipped  : (-1,1)_blendingData
Skipped  : (-1,1)_actorDigestVersion

Done!
============= keys =============
Total     : 47
Extracted : 27
Unknown   : 0
--------------------------------
Output limit for each directory is 10.
Actor     : 4
Digp      : 5
Map       : 0
Village   : 0
Subchunk  : Overworld=30, TheNether=0, TheEnd=0
Others    : 8
```

Extract and save data to files by specified keys.
```bash
❯  ./mcp extract-all --override -l 10 -acdmv --src {{path-to-directory-contains-db}} --dst {{path-to-output-directory}}

========== ========== ========== ========== ========== ==========
Extracting data ...)
    from {{path-to-directory-contains-db}}/db
    to {{path-to-output-directory}}

Extracted: (0,1)_data3D
Extracted: (0,1)_chunkVersion
Extracted: (0,1)_subChunkPrefix(-4)
Extracted: (0,1)_finalizedState
Extracted: (0,1)_metaDataHash
Extracted: (0,1)_blendingData
Extracted: (0,1)_actorDigestVersion
Extracted: (0,2)_data3D
Extracted: (0,2)_chunkVersion
Extracted: (0,2)_subChunkPrefix(-4)
Skipped  : (0,2)_finalizedState
Skipped  : (0,2)_metaDataHash
Skipped  : (0,2)_blendingData
Skipped  : (0,2)_actorDigestVersion
Skipped  : (0,-3)_data3D
Skipped  : (0,-3)_chunkVersion
Skipped  : (0,-3)_subChunkPrefix(-4)
Skipped  : (0,-3)_finalizedState
Skipped  : (0,-3)_metaDataHash
Skipped  : (0,-3)_blendingData
Skipped  : (0,-3)_actorDigestVersion
Skipped  : (1,2)_finalizedState
Skipped  : (1,2)_actorDigestVersion
Extracted: AutonomousEntities
Extracted: BiomeData
Extracted: LevelChunkMetaDataDictionary
Extracted: Overworld
Extracted: actorprefix_0x00_00_00_01_00_00_00_02
Extracted: actorprefix_0x00_00_00_01_00_00_00_03
Extracted: actorprefix_0x00_00_00_01_00_00_00_04
Extracted: actorprefix_0x00_00_00_01_00_00_00_05
Extracted: digp_(0,1)
Extracted: digp_(0,2)
Extracted: digp_(0,-3)
Extracted: digp_(1,2)
Extracted: digp_(-1,1)
Extracted: mobevents
Extracted: schedulerWT
Extracted: scoreboard
Extracted: ~local_player
Skipped  : (-1,1)_data3D
Skipped  : (-1,1)_chunkVersion
Skipped  : (-1,1)_subChunkPrefix(-4)
Skipped  : (-1,1)_finalizedState
Skipped  : (-1,1)_metaDataHash
Skipped  : (-1,1)_blendingData
Skipped  : (-1,1)_actorDigestVersion
Remove empty directory: output/maps
Remove empty directory: output/structures
Remove empty directory: output/players
Remove empty directory: output/chunks/end
Remove empty directory: output/chunks/nether
Remove empty directory: output/Unknown
Remove empty directory: output/villages

Done!
============= keys =============
Total     : 47
Extracted : 27
Unknown   : 0
--------------------------------
Output limit for each directory is 10.
Actor     : 4
Digp      : 5
Map       : 0
Village   : 0
Subchunk  : Overworld=30, TheNether=0, TheEnd=0
Others    : 8

❯  tree {{path-to-output-directory}}
{{path-to-output-directory}}
├── actorprefix
│   ├── actorprefix_0x00_00_00_01_00_00_00_02.nbt
│   ├── actorprefix_0x00_00_00_01_00_00_00_03.nbt
│   ├── actorprefix_0x00_00_00_01_00_00_00_04.nbt
│   └── actorprefix_0x00_00_00_01_00_00_00_05.nbt
├── chunks
│   └── overworld
│       ├── (0,1)_actorDigestVersion
│       ├── (0,1)_blendingData
│       ├── (0,1)_chunkVersion
│       ├── (0,1)_data3D
│       ├── (0,1)_finalizedState
│       ├── (0,1)_metaDataHash
│       ├── (0,1)_subChunkPrefix(-4)
│       ├── (0,2)_chunkVersion
│       ├── (0,2)_data3D
│       └── (0,2)_subChunkPrefix(-4)
├── digp
│   ├── digp_(-1,1)
│   ├── digp_(0,-3)
│   ├── digp_(0,1)
│   ├── digp_(0,2)
│   └── digp_(1,2)
└── wellKnown
    ├── AutonomousEntities.nbt
    ├── BiomeData.nbt
    ├── LevelChunkMetaDataDictionary.nbt
    ├── Overworld.nbt
    ├── mobevents.nbt
    ├── schedulerWT.nbt
    ├── scoreboard.nbt
    └── ~local_player.nbt

6 directories, 27 files

```
