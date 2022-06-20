#!/usr/bin/env sh

set -xe

prisma db pull --schema prisma/back.prisma
cp -f prisma/back.prisma prisma/transformer.prisma
prisma-schema-trans prisma/transformer.prisma

cat > prisma/schema.prisma <<- EOM
generator nestjsDto {
  provider                        = "prisma-generator-nestjs-dto"
  output                          = "../src/model"
  outputToNestJsResourceStructure = "true"
  reExport                        = "true"
  fileNamingStyle                 = "kebab"
}

EOM

BASEDIR=$(dirname "$0")

"$BASEDIR"/schema.awk prisma/back.prisma | paste prisma/transformer.prisma - >> prisma/schema.prisma

unset BASEDIR;

prisma format
prisma generate
