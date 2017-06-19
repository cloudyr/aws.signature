pkg = $(shell basename $(CURDIR))

all: build

NAMESPACE: R/*
	Rscript -e "devtools::document()"

README.html: README.md
	pandoc -o README.html README.md

../$(pkg)*.tar.gz: DESCRIPTION NAMESPACE README.md R/* tests/*
	cd ../ && R CMD build $(pkg)

build: ../$(pkg)*.tar.gz

check: ../$(pkg)*.tar.gz
	cd ../ && R CMD check $(pkg)*.tar.gz
	rm ../$(pkg)*.tar.gz

revdep: ../$(pkg)*.tar.gz
	Rscript -e "devtools::revdep_check()"

install: ../$(pkg)*.tar.gz
	cd ../ && R CMD INSTALL $(pkg)*.tar.gz
	rm ../$(pkg)*.tar.gz
