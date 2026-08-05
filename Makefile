all: rpm

rpm: clean
	$(MAKE) -C packaging/rpm

clean:
	$(MAKE) -C packaging/rpm clean

rpm: clean
	$(MAKE) -C packaging/rpm rpm

srpm: clean
	$(MAKE) -C packaging/rpm srpm

distclean: clean
	$(MAKE) -C packaging/rpm distclean
