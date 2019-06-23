FROM gentoo/portage:latest as portage
FROM liftm/gentoo-uclibc:stage3 as static
COPY --from=portage /usr/portage /usr/portage

RUN true \
	&& echo 'CONFIG_PROTECT="-*"' >>/etc/portage/make.conf \
	&& echo 'USE="static static-libs"' >>/etc/portage/make.conf \
	&& echo 'FEATURES="-sandbox -ipc-sandbox -network-sandbox -pid-sandbox -usersandbox"' >>/etc/portage/make.conf # can't sandbox in the sandbox \
	&& sed -i '/^\/usr\/lib$/ d; /^\/lib$/ d;' /etc/ld.so.conf

RUN emerge --unmerge openssh ssh \
	&& emerge --autounmask-write --autounmask-continue --tree --verbose --empty --keep-going \
		--exclude='openssh ssh' \
		--exclude='gzip bzip2 tar xz' \
		--exclude='debianutils patch pinentry baselayout' \
		@world

RUN rm -rf /usr/portage

FROM scratch
COPY --from=static / /
