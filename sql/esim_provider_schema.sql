create table if not exists esim_provider (
  id                    bigserial primary key,
  code                  varchar(64) not null unique,
  name                  varchar(128) not null,
  status                varchar(16) not null,
  callback_ip_whitelist text,
  create_time           timestamp not null default now(),
  update_time           timestamp not null default now()
);
comment on table esim_provider is '供应商主表';
comment on column esim_provider.id is '主键ID';
comment on column esim_provider.code is '业务编码，供应商编码';
comment on column esim_provider.name is '名称，供应商名称';
comment on column esim_provider.status is '状态：ENABLED=启用，DISABLED=禁用';
comment on column esim_provider.callback_ip_whitelist is '回调IP白名单，多个IP用逗号分隔';
comment on column esim_provider.create_time is '创建时间';
comment on column esim_provider.update_time is '更新时间';

create table if not exists esim_provider_sync (
  id             bigserial primary key,
  provider_id    bigint not null,
  trigger_type   varchar(16) not null,
  result         varchar(16) not null,
  sync_count     integer not null default 0,
  error_message  text,
  started_time   timestamp,
  finished_time  timestamp,
  create_time    timestamp not null default now()
);
comment on table esim_provider_sync is '供应商同步记录';
comment on column esim_provider_sync.id is '主键ID';
comment on column esim_provider_sync.provider_id is '关联ID，供应商ID';
comment on column esim_provider_sync.trigger_type is '触发类型：SCHEDULE=定时，MANUAL=手动，RETRY=重试';
comment on column esim_provider_sync.result is '执行结果：PROCESSING=同步中，SUCCESS=成功，FAILED=失败，PARTIAL=部分成功';
comment on column esim_provider_sync.sync_count is '同步数量';
comment on column esim_provider_sync.error_message is '错误信息';
comment on column esim_provider_sync.started_time is '开始时间';
comment on column esim_provider_sync.finished_time is '结束时间';
comment on column esim_provider_sync.create_time is '创建时间';

create index if not exists idx_provider_sync_ptime
  on esim_provider_sync(provider_id, create_time desc);
create index if not exists idx_provider_sync_result
  on esim_provider_sync(result, create_time desc);

create table if not exists esim_provider_operator (
  id            bigserial primary key,
  provider_id   bigint not null,
  code_raw      varchar(64) not null,
  code          varchar(64) not null,
  code_match    integer not null default 0,
  slug          varchar(128) not null,
  name          varchar(256),
  currency      varchar(8) not null,
  price         numeric(18, 6),
  price_plan_time timestamp,
  price_plan_value numeric(18, 6),
  country_iso2  varchar(8) not null,
  regions       text[],
  network_type  varchar(64),
  mcc           varchar(8),
  mnc           varchar(8),
  status        varchar(16) not null,
  search_text   text,
  remark        text,
  create_time   timestamp not null default now(),
  update_time   timestamp not null default now(),
  unique(provider_id, code_raw)
);
comment on table esim_provider_operator is '供应商运营商字典';
comment on column esim_provider_operator.id is '主键ID';
comment on column esim_provider_operator.provider_id is '关联ID，供应商ID';
comment on column esim_provider_operator.code_raw is '业务编码，运营商原始编码';
comment on column esim_provider_operator.code is '业务编码，运营商标准编码';
comment on column esim_provider_operator.code_match is '是否已配置code';
comment on column esim_provider_operator.name is '运营商展示名称';
comment on column esim_provider_operator.create_time is '创建时间';
comment on column esim_provider_operator.update_time is '更新时间';
comment on column esim_provider_operator.slug is '运营商slug';
comment on column esim_provider_operator.price is '价格';
comment on column esim_provider_operator.price_plan_time is '价格计划时间';
comment on column esim_provider_operator.price_plan_value is '价格计划值（最终价格）';
comment on column esim_provider_operator.country_iso2 is '国家ISO2编码';
comment on column esim_provider_operator.regions is '所属区域数组';
comment on column esim_provider_operator.network_type is '网络类型';
comment on column esim_provider_operator.mcc is 'MCC';
comment on column esim_provider_operator.mnc is 'MNC';
comment on column esim_provider_operator.status is '状态';
comment on column esim_provider_operator.search_text is '搜索文本';
comment on column esim_provider_operator.remark is '备注';

create index if not exists idx_provider_operator_slug
  on esim_provider_operator(slug);
create index if not exists idx_provider_operator_price_plan_time
  on esim_provider_operator(price_plan_time);

create table if not exists esim_provider_esim (
  id                bigserial primary key,
  provider_id       bigint not null,
  iccid             varchar(64) not null unique,
  msisdn            varchar(64),
  imsi              varchar(64),
  operator_code_raw varchar(64),
  eid               varchar(64),
  smdp_status       varchar(64),
  install_count     integer,
  install_device    varchar(128),
  install_time      timestamp,
  activation_code   text,
  pin               varchar(12),
  puk               varchar(12),
  allocable         integer not null default 1,
  occupancy_status  varchar(16) not null default 'FREE',
  status            varchar(16) not null,
  allocated_time    timestamp,
  activated_time    timestamp,
  expired_time      timestamp,
  last_sync_time    timestamp,
  create_time       timestamp not null default now(),
  update_time       timestamp not null default now()
);
comment on table esim_provider_esim is '供应商eSIM号池';
comment on column esim_provider_esim.id is '主键ID';
comment on column esim_provider_esim.provider_id is '关联ID，供应商ID';
comment on column esim_provider_esim.iccid is 'ICCID';
comment on column esim_provider_esim.msisdn is 'MSISDN号码';
comment on column esim_provider_esim.imsi is 'IMSI';
comment on column esim_provider_esim.operator_code_raw is '供应商原始运营商编码';
comment on column esim_provider_esim.eid is 'EID';
comment on column esim_provider_esim.smdp_status is 'SMDP状态';
comment on column esim_provider_esim.install_count is '安装次数';
comment on column esim_provider_esim.install_device is '安装设备';
comment on column esim_provider_esim.install_time is '安装时间';
comment on column esim_provider_esim.activation_code is 'Activation Code字符串';
comment on column esim_provider_esim.pin is 'PIN码';
comment on column esim_provider_esim.puk is 'PUK码';
comment on column esim_provider_esim.allocable is '是否可分配使用';
comment on column esim_provider_esim.occupancy_status is '占用状态：FREE=空闲，RESERVED=预占，USED=已使用';
comment on column esim_provider_esim.status is '状态：ENABLED=启用，DISABLED=禁用';
comment on column esim_provider_esim.allocated_time is '分配时间';
comment on column esim_provider_esim.activated_time is '激活时间';
comment on column esim_provider_esim.expired_time is '过期时间';
comment on column esim_provider_esim.last_sync_time is '最近同步时间';
comment on column esim_provider_esim.create_time is '创建时间';
comment on column esim_provider_esim.update_time is '更新时间';

create index if not exists idx_provider_esim_status
  on esim_provider_esim(provider_id, status);

create table if not exists esim_partner (
  id             bigserial primary key,
  code           varchar(64) not null unique,
  name           varchar(128) not null,
  region         varchar(64),
  contact_name   varchar(64) not null,
  email          varchar(128) not null unique,
  phone          varchar(32) not null,
  status         varchar(16) not null,
  billing_mode   varchar(16) not null,
  settlement_mode varchar(16) not null,
  guide_plan_id  bigint,
  remark         text,
  search_text    text,
  create_time    timestamp not null default now(),
  update_time    timestamp not null default now()
);
comment on table esim_partner is '客户主表';
comment on column esim_partner.id is '主键ID';
comment on column esim_partner.code is '业务编码 客户编码';
comment on column esim_partner.name is '名称 客户名称';
comment on column esim_partner.region is '所属地区';
comment on column esim_partner.contact_name is '名称 联系人';
comment on column esim_partner.email is '邮箱';
comment on column esim_partner.phone is '手机号';
comment on column esim_partner.status is '状态：ENABLED=启用，DISABLED=禁用，PENDING=待审核';
comment on column esim_partner.billing_mode is '计费模式：PACKAGE=按套餐，PER_GB=按GB';
comment on column esim_partner.settlement_mode is '结算方式：PREPAID=预付，POSTPAID=后付';
comment on column esim_partner.guide_plan_id is '关联ID 导购价模板ID';
comment on column esim_partner.remark is '备注';
comment on column esim_partner.search_text is '搜索文本';
comment on column esim_partner.create_time is '创建时间';
comment on column esim_partner.update_time is '更新时间';

create index if not exists idx_partner_status on esim_partner(status);

create table if not exists esim_package (
  id                    bigserial primary key,
  code                  varchar(64) not null unique,
  slug                  varchar(128) not null,
  tag                   varchar(128) not null,
  provider_id           bigint not null,
  code_raw              varchar(128) not null,
  name_raw              varchar(256),
  name                  varchar(256) not null,
  type                  varchar(16) not null,
  data                  bigint,
  data_unit             varchar(16),
  data_raw              bigint,
  data_unit_raw         varchar(16),
  limit_type            varchar(32),
  limit_control         varchar(32),
  duration              integer,
  duration_unit         varchar(16),
  speed                 varchar(16),
  billing_mode          varchar(16) not null,
  currency              varchar(8) not null,
  price_raw             numeric(18, 6),
  price                 numeric(18, 6),
  price_plan_time       timestamp,
  price_plan_value      numeric(18, 6),
  version               integer not null default 0,
  support_top_up        integer not null default 0,
  source_status         varchar(16),
  status                varchar(16) not null,
  last_sync_time        timestamp,
  coverage              text[],
  regions               text[],
  create_time           timestamp not null default now(),
  update_time           timestamp not null default now(),
  unique(provider_id, code_raw)
);
comment on table esim_package is '套餐目录';
comment on column esim_package.id is '主键ID';
comment on column esim_package.code is '业务编码 套餐编码';
comment on column esim_package.tag is '标签';
comment on column esim_package.slug is '由关键信息拼接生成，可用于排序、搜索';
comment on column esim_package.provider_id is '关联ID 供应商ID';
comment on column esim_package.code_raw is '关联ID 供应商原始套餐ID';
comment on column esim_package.name_raw is '供应商原始套餐名称';
comment on column esim_package.name is '名称 套餐名称';
comment on column esim_package.type is '套餐类型：COUNTRY=国家包，REGION=区域包，GLOBAL=全球包';
comment on column esim_package.coverage is '覆盖范围数组';
comment on column esim_package.regions is '冗余区域数组';
comment on column esim_package.data is '流量';
comment on column esim_package.data_unit is '流量单位：MB=兆，GB=千兆';
comment on column esim_package.data_raw is '原始流量值';
comment on column esim_package.data_unit_raw is '原始流量单位';
comment on column esim_package.duration is '周期数值';
comment on column esim_package.duration_unit is '周期单位：HOURS24=24小时，DAY=日，MONTH=月';
comment on column esim_package.speed is '速率等级';
comment on column esim_package.billing_mode is '计费模式：PACKAGE=按套餐，PER_GB=按GB';
comment on column esim_package.currency is '币种';
comment on column esim_package.price is '价格';
comment on column esim_package.price_plan_time is '价格计划时间';
comment on column esim_package.price_plan_value is '价格计划值（最终价格）';
comment on column esim_package.support_top_up is '是否支持加油包：1=支持，0=不支持';
comment on column esim_package.source_status is '源状态：状态：ENABLED=启用，DISABLED=禁用。供应商套餐是否存在、可用等原始状态';
comment on column esim_package.status is '状态：ON_SALE=在售，OFF_SALE=停售';
comment on column esim_package.last_sync_time is '最近同步时间';
comment on column esim_package.create_time is '创建时间';
comment on column esim_package.update_time is '更新时间';
comment on column esim_package.version is '版本';
comment on column esim_package.limit_type is '流量限制类型';
comment on column esim_package.limit_control is '限速控制逻辑';
comment on column esim_package.price_raw is '同步原始价格';
create index if not exists idx_package_slug
  on esim_package(slug);
create index if not exists idx_package_tag
  on esim_package(tag);
create index if not exists idx_package_price_plan_time
  on esim_package(price_plan_time);

create table if not exists esim_gb_price_item (
  id                bigserial primary key,
  owner_type        varchar(16) not null,
  owner_id          bigint not null,
  provider_id       bigint not null,
  operator_id       bigint not null,
  operator_code     varchar(64) not null,
  slug              varchar(128) not null,
  name              varchar(256),
  country_iso2      varchar(8),
  regions           text[],
  network_type      varchar(64),
  mcc               varchar(8),
  mnc               varchar(8),
  currency          varchar(8) not null,
  cost_price        numeric(18, 6),
  cost_price_plan_time timestamp,
  cost_price_plan_value numeric(18, 6),
  sale_price_strategy   varchar(32),
  sale_price        numeric(18, 6) not null,
  price_plan_time   timestamp,
  sale_price_plan_value numeric(18, 6),
  retail_price_strategy     varchar(32),
  retail_price      numeric(18, 6) not null,
  retail_price_plan_value numeric(18, 6),
  status            varchar(16) not null,
  search_text       text,
  remark            text,
  create_time       timestamp not null default now(),
  update_time       timestamp not null default now(),
  unique(owner_type, owner_id, operator_id)
);
comment on table esim_gb_price_item is 'GB价格项';
comment on column esim_gb_price_item.id is '主键ID';
comment on column esim_gb_price_item.owner_type is '归属类型：GUIDE=指导价，SPECIAL=特殊价';
comment on column esim_gb_price_item.owner_id is '关联ID 归属对象ID';
comment on column esim_gb_price_item.provider_id is '关联ID 供应商ID';
comment on column esim_gb_price_item.operator_id is '关联ID 运营商ID';
comment on column esim_gb_price_item.operator_code is '运营商标准编码';
comment on column esim_gb_price_item.slug is '排序/搜索slug';
comment on column esim_gb_price_item.name is '名称';
comment on column esim_gb_price_item.country_iso2 is '国家ISO2编码';
comment on column esim_gb_price_item.regions is '覆盖区域数组';
comment on column esim_gb_price_item.network_type is '网络类型';
comment on column esim_gb_price_item.mcc is 'MCC';
comment on column esim_gb_price_item.mnc is 'MNC';
comment on column esim_gb_price_item.currency is '币种';
comment on column esim_gb_price_item.cost_price is '成本单价(每GB)';
comment on column esim_gb_price_item.cost_price_plan_time is '成本计划时间';
comment on column esim_gb_price_item.cost_price_plan_value is '成本计划价格';
comment on column esim_gb_price_item.sale_price_strategy is '销售价定价策略';
comment on column esim_gb_price_item.sale_price is '销售价';
comment on column esim_gb_price_item.price_plan_time is '销售/零售计划时间';
comment on column esim_gb_price_item.sale_price_plan_value is '销售计划价格';
comment on column esim_gb_price_item.retail_price_strategy is '零售价定价策略';
comment on column esim_gb_price_item.retail_price is '零售价';
comment on column esim_gb_price_item.retail_price_plan_value is '零售计划价格';
comment on column esim_gb_price_item.status is '状态：ON_SALE=在售，OFF_SALE=下架';
comment on column esim_gb_price_item.search_text is '搜索文本';
comment on column esim_gb_price_item.remark is '备注';
comment on column esim_gb_price_item.create_time is '创建时间';
comment on column esim_gb_price_item.update_time is '更新时间';

create index if not exists idx_gb_price_item_price_plan_time
  on esim_gb_price_item(price_plan_time);

create table if not exists esim_package_country_operator (
  id                   bigserial primary key,
  provider_id          bigint not null,
  package_code         varchar(64) not null,
  country_iso2         varchar(8) not null,
  operator_id          bigint not null,
  regions              text[],
  mcc                  varchar(8),
  mnc                  varchar(8)
);
comment on table esim_package_country_operator is '套餐国家运营商映射';
comment on column esim_package_country_operator.id is '主键ID';
comment on column esim_package_country_operator.provider_id is '关联ID 供应商ID';
comment on column esim_package_country_operator.country_iso2 is '国家ISO2编码';
comment on column esim_package_country_operator.operator_id is '关联ID 运营商ID';
comment on column esim_package_country_operator.regions is '所属区域数组';
comment on column esim_package_country_operator.mcc is 'MCC';
comment on column esim_package_country_operator.mnc is 'MNC';
comment on column esim_package_country_operator.package_code is '鍏宠仈ID 濂楅缂栫爜';

create index if not exists idx_package_country_operator_country_operator
  on esim_package_country_operator(country_iso2, operator_id);
create unique index if not exists idx_package_country_operator_lookup
  on esim_package_country_operator(package_code, country_iso2, operator_id);

comment on table esim_package_country_operator is '套餐国家运营商映射';
comment on column esim_package_country_operator.id is '主键ID';
comment on column esim_package_country_operator.provider_id is '关联ID 供应商ID';
comment on column esim_package_country_operator.package_code is '关联ID 套餐编码';
comment on column esim_package_country_operator.country_iso2 is '国家ISO2编码';
comment on column esim_package_country_operator.operator_id is '关联ID 运营商ID';
comment on column esim_package_country_operator.regions is '所属区域数组';
comment on column esim_package_country_operator.mcc is 'MCC';
comment on column esim_package_country_operator.mnc is 'MNC';

create table if not exists esim_top_up (
  id                bigserial primary key,
  provider_id       bigint not null,
  package_code      varchar(64) not null,
  code              varchar(64) not null unique,
  slug              varchar(128) not null,
  package_code_raw  varchar(128) not null,
  code_raw          varchar(64),
  data              bigint not null,
  data_unit         varchar(16) not null,
  data_raw          bigint not null,
  data_unit_raw     varchar(16),
  currency          varchar(8) not null,
  price_raw         numeric(18, 6),
  price             numeric(18, 6),
  price_plan_time   timestamp,
  price_plan_value  numeric(18, 6),
  source_status     varchar(16),
  last_sync_time      timestamp,
  create_time        timestamp not null default now(),
  update_time        timestamp not null default now()
);
comment on table esim_top_up is '加油包目录';
comment on column esim_top_up.id is '主键ID';
comment on column esim_top_up.package_code is '关联ID 套餐编码';
comment on column esim_top_up.package_code_raw is '关联ID 供应商原始套餐ID';
comment on column esim_top_up.code is '业务编码';
comment on column esim_top_up.slug is '由关键信息拼接生成，可用于排序、搜索';
comment on column esim_top_up.data is '流量值';
comment on column esim_top_up.data_unit is '流量单位';
comment on column esim_top_up.data_raw is '原始流量值';
comment on column esim_top_up.currency is '币种';
comment on column esim_top_up.price is '价格';
comment on column esim_top_up.price_plan_time is '价格计划时间';
comment on column esim_top_up.price_plan_value is '价格计划值（最终价格）';
comment on column esim_top_up.last_sync_time is '最近同步时间';
comment on column esim_top_up.create_time is '创建时间';
comment on column esim_top_up.update_time is '更新时间';
comment on column esim_top_up.data_unit_raw is '原始流量单位';
comment on column esim_top_up.provider_id is '关联ID 供应商ID';
comment on column esim_top_up.price_raw is '同步原始价格';
comment on column esim_top_up.code_raw is '关联ID 供应商原始加油包ID';
comment on column esim_top_up.source_status is '源状态';

create index if not exists idx_top_up_package_code_code
  on esim_top_up(package_code, code);

create index if not exists idx_top_up_slug
  on esim_top_up(slug);
create index if not exists idx_top_up_price_plan_time
  on esim_top_up(price_plan_time);


create table if not exists esim_guide_price_plan (
  id                bigserial primary key,
  name              varchar(128) not null,
  system_default    integer not null default 0,
  remark            text,
  create_time        timestamp not null default now(),
  update_time        timestamp not null default now()
);
comment on table esim_guide_price_plan is '指导价模板';
comment on column esim_guide_price_plan.id is '主键ID';
comment on column esim_guide_price_plan.name is '名称 模板名称';
comment on column esim_guide_price_plan.system_default is '是否系统默认模板';
comment on column esim_guide_price_plan.remark is '备注';
comment on column esim_guide_price_plan.create_time is '创建时间';
comment on column esim_guide_price_plan.update_time is '更新时间';

create table if not exists esim_price_item (
  id                bigserial primary key,
  parent_id         bigint,
  owner_type        varchar(16) not null,
  owner_id          bigint not null,
  provider_id       bigint,
  product_type      varchar(16) not null,
  product_code      varchar(64) not null,
  slug              varchar(128) not null,
  name              varchar(256),
  type              varchar(16),
  data              bigint,
  data_unit         varchar(16),
  duration          integer,
  duration_unit     varchar(16),
  speed             varchar(16),
  billing_mode      varchar(16),
  currency          varchar(8) not null,
  cost_price        numeric(18, 6),
  cost_price_plan_time timestamp,
  cost_price_plan_value numeric(18, 6),
  support_top_up    integer not null,
  sale_price_strategy varchar(32),
  sale_price        numeric(18, 6) not null,
  price_plan_time   timestamp,
  sale_price_plan_value numeric(18, 6),
  retail_price_strategy varchar(32),
  retail_price      numeric(18, 6) not null,
  retail_price_plan_value numeric(18, 6),
  status            varchar(16) not null,
  coverage          text[],
  regions           text[],
  create_time       timestamp not null default now(),
  update_time       timestamp not null default now(),
  unique(owner_type, owner_id, product_type, product_code)
);
comment on table esim_price_item is '价格明细';
comment on column esim_price_item.id is '主键ID';
comment on column esim_price_item.owner_type is '归属类型：GUIDE=指导价，SPECIAL=特殊价';
comment on column esim_price_item.owner_id is '关联ID 归属对象ID(按owner_type解释)';
comment on column esim_price_item.provider_id is '关联ID 供应商ID';
comment on column esim_price_item.product_type is '产品类型：PACKAGE=套餐，TOP_UP=加油包';
comment on column esim_price_item.product_code is '产品编码(按product_type解释)';
comment on column esim_price_item.slug is '由关键信息拼接生成，可用于排序、搜索';
comment on column esim_price_item.name is '名称 套餐名称';
comment on column esim_price_item.type is '套餐类型，对应 esim_package.type';
comment on column esim_price_item.data is '流量';
comment on column esim_price_item.data_unit is '流量单位：MB=兆，GB=千兆';
comment on column esim_price_item.duration is '周期数值';
comment on column esim_price_item.duration_unit is '周期单位：HOURS24=24小时，DAY=日，MONTH=月';
comment on column esim_price_item.speed is '速率等级';
comment on column esim_price_item.billing_mode is '计费模式：PACKAGE=按套餐，PER_GB=按GB';
comment on column esim_price_item.currency is '币种';
comment on column esim_price_item.cost_price is '成本价格';
comment on column esim_price_item.cost_price_plan_time is '成本计划时间';
comment on column esim_price_item.cost_price_plan_value is '成本计划价格';
comment on column esim_price_item.support_top_up is '是否支持加油包：1=支持，0=不支持';
comment on column esim_price_item.sale_price_strategy is '销售价定价策略值，如固定额20或利率120%';
comment on column esim_price_item.sale_price is '销售价';
comment on column esim_price_item.price_plan_time is '销售/零售计划时间';
comment on column esim_price_item.sale_price_plan_value is '销售计划价格';
comment on column esim_price_item.retail_price_strategy is '零售价定价策略值，如固定额20或利率120%';
comment on column esim_price_item.retail_price is '建议零售价';
comment on column esim_price_item.retail_price_plan_value is '零售计划价格';
comment on column esim_price_item.status is '状态：ON_SALE=在售，OFF_SALE=下架';
comment on column esim_price_item.coverage is '覆盖范围数组';
comment on column esim_price_item.regions is '覆盖区域数组';
comment on column esim_price_item.create_time is '创建时间';
comment on column esim_price_item.update_time is '更新时间';

create index if not exists idx_price_item_lookup
  on esim_price_item(product_type, product_code, owner_type, owner_id);

create index if not exists idx_price_item_parent_id
  on esim_price_item(parent_id);

create index if not exists idx_price_item_slug
  on esim_price_item(slug);
create index if not exists idx_price_item_price_plan_time
  on esim_price_item(price_plan_time);

create table if not exists esim_partner_api (
  id                bigserial primary key,
  partner_id        bigint not null unique,
  access_key        varchar(128) not null unique,
  access_secret     text not null,
  status            varchar(16) not null,
  webhook_url       text,
  ip_whitelist      text,
  update_time       timestamp not null default now()
);

comment on table esim_partner_api is '客户API配置';
comment on column esim_partner_api.partner_id is '关联ID 客户ID';
comment on column esim_partner_api.access_key is 'Access Key';
comment on column esim_partner_api.access_secret is 'Access Secret';
comment on column esim_partner_api.status is 'API状态：ENABLED=启用，DISABLED=禁用';
comment on column esim_partner_api.webhook_url is 'Webhook地址';
comment on column esim_partner_api.ip_whitelist is 'IP白名单';
comment on column esim_partner_api.update_time is '更新时间';

create table if not exists esim_package_effective (
  id                    bigserial primary key,
  partner_id            bigint not null,
  package_code          varchar(64) not null,
  slug                  varchar(128) not null,
  tag                   varchar(128) not null,
  provider_id           bigint not null,
  name                  varchar(256) not null,
  type                  varchar(16) not null,
  data                  bigint,
  data_unit             varchar(16),
  duration              integer,
  duration_unit         varchar(16),
  speed                 varchar(16),
  billing_mode          varchar(16) not null,
  currency              varchar(8) not null,
  price                 numeric(18, 6),
  retail_price          numeric(18, 6) not null,
  price_plan_time       timestamp,
  price_plan_value      numeric(18, 6),
  retail_price_plan_value   numeric(18, 6),
  version               integer not null default 0,
  support_top_up        integer not null default 0,
  coverage              text[],
  regions               text[],
  create_time           timestamp not null default now(),
  update_time           timestamp not null default now(),
  unique(partner_id, package_code)
);

comment on table esim_package_effective is '套餐目录';
comment on column esim_package_effective.id is '主键ID';
comment on column esim_package_effective.package_code is '套餐编码';
comment on column esim_package_effective.tag is '标签';
comment on column esim_package_effective.slug is 'slug，由关键信息拼接生成，可用于排序和搜索';
comment on column esim_package_effective.provider_id is '供应商ID';
comment on column esim_package_effective.name is '套餐名称';
comment on column esim_package_effective.type is '套餐类型：COUNTRY=国家包，REGION=区域包，GLOBAL=全球包';
comment on column esim_package_effective.coverage is '覆盖范围数组';
comment on column esim_package_effective.regions is '区域数组';
comment on column esim_package_effective.data is '流量';
comment on column esim_package_effective.data_unit is '流量单位：MB=兆，GB=千兆';
comment on column esim_package_effective.duration is '周期数值';
comment on column esim_package_effective.duration_unit is '周期单位：HOURS24=24小时，DAY=日，MONTH=月';
comment on column esim_package_effective.speed is '速率等级';
comment on column esim_package_effective.billing_mode is '计费模式：PACKAGE=按套餐，PER_GB=按GB';
comment on column esim_package_effective.currency is '币种';
comment on column esim_package_effective.price is '价格';
comment on column esim_package_effective.price_plan_time is '价格计划时间';
comment on column esim_package_effective.price_plan_value is '价格计划值';
comment on column esim_package_effective.support_top_up is '是否支持加油包：1=支持，0=不支持';
comment on column esim_package_effective.create_time is '创建时间';
comment on column esim_package_effective.update_time is '更新时间';
comment on column esim_package_effective.version is '版本';
comment on column esim_package_effective.partner_id is '合作伙伴ID';
comment on column esim_package_effective.retail_price is '零售价';
comment on column esim_package_effective.retail_price_plan_value is '零售价格计划值';
create index if not exists idx_package_partner_slug
  on esim_package_effective(partner_id, slug);
create index if not exists idx_package_partner_tag
  on esim_package_effective(partner_id, tag);
create index if not exists idx_package_price_plan_time
  on esim_package_effective(price_plan_time);

create table if not exists esim_top_up_effective (
  id                bigserial primary key,
  partner_id        bigint not null,
  package_code      varchar(64) not null,
  provider_id       bigint not null,
  top_up_code       varchar(64) not null,
  slug              varchar(128) not null,
  data              bigint not null,
  data_unit         varchar(16) not null,
  currency          varchar(8) not null,
  price             numeric(18, 6),
  price_plan_time   timestamp,
  price_plan_value  numeric(18, 6),
  create_time       timestamp not null default now(),
  update_time       timestamp not null default now(),
  unique(partner_id, top_up_code)
);

comment on table esim_top_up_effective is '加油包有效目录';
comment on column esim_top_up_effective.id is '主键ID';
comment on column esim_top_up_effective.partner_id is '关联ID 合作伙伴ID';
comment on column esim_top_up_effective.package_code is '关联ID 套餐编码';
comment on column esim_top_up_effective.provider_id is '关联ID 供应商ID';
comment on column esim_top_up_effective.top_up_code is '加油包编码';
comment on column esim_top_up_effective.slug is 'slug，由关键信息拼接生成，可用于排序和搜索';
comment on column esim_top_up_effective.data is '流量值';
comment on column esim_top_up_effective.data_unit is '流量单位';
comment on column esim_top_up_effective.currency is '币种';
comment on column esim_top_up_effective.price is '价格';
comment on column esim_top_up_effective.price_plan_time is '价格计划时间';
comment on column esim_top_up_effective.price_plan_value is '价格计划值';
comment on column esim_top_up_effective.create_time is '创建时间';
comment on column esim_top_up_effective.update_time is '更新时间';

create table if not exists esim_gb_price_effective (
  id                bigserial primary key,
  partner_id        bigint not null,
  provider_id       bigint not null,
  operator_id       bigint not null,
  operator_code     varchar(64) not null,
  slug              varchar(128) not null,
  name              varchar(256),
  country_iso2      varchar(8),
  regions           text[],
  network_type      varchar(64),
  mcc               varchar(8),
  mnc               varchar(8),
  currency          varchar(8) not null,
  price             numeric(18, 6) not null,
  price_plan_time   timestamp,
  price_plan_value  numeric(18, 6),
  create_time       timestamp not null default now(),
  update_time       timestamp not null default now(),
  unique(partner_id, operator_id)
);

comment on table esim_gb_price_effective is '按GB有效价格目录';
comment on column esim_gb_price_effective.id is '主键ID';
comment on column esim_gb_price_effective.partner_id is '关联ID 合作伙伴ID';
comment on column esim_gb_price_effective.provider_id is '关联ID 供应商ID';
comment on column esim_gb_price_effective.operator_id is '关联ID 运营商ID';
comment on column esim_gb_price_effective.operator_code is '运营商编码';
comment on column esim_gb_price_effective.slug is 'slug，由关键信息拼接生成，可用于排序和搜索';
comment on column esim_gb_price_effective.name is '运营商名称';
comment on column esim_gb_price_effective.country_iso2 is '国家ISO2编码';
comment on column esim_gb_price_effective.regions is '区域数组';
comment on column esim_gb_price_effective.network_type is '网络类型';
comment on column esim_gb_price_effective.mcc is 'MCC';
comment on column esim_gb_price_effective.mnc is 'MNC';
comment on column esim_gb_price_effective.currency is '币种';
comment on column esim_gb_price_effective.price is '价格';
comment on column esim_gb_price_effective.price_plan_time is '价格计划时间';
comment on column esim_gb_price_effective.price_plan_value is '价格计划值';
comment on column esim_gb_price_effective.create_time is '创建时间';
comment on column esim_gb_price_effective.update_time is '更新时间';

create table if not exists esim_order (
  id                bigserial primary key,
  partner_id        bigint not null,
  order_code        varchar(128) not null unique,
  transaction_id    varchar(128) not null,
  product_type      varchar(16) not null,
  currency          varchar(8) not null,
  amount            numeric(18, 6) not null,
  quantity          integer not null default 0,
  iccids            text,
  status            varchar(16) not null,

  delete_flag       integer not null default 0,
  delete_time       timestamp,
  create_time       timestamp not null default now(),
  update_time       timestamp not null default now(),
  unique(partner_id, transaction_id)
);

comment on table esim_order is '订单主表';
comment on column esim_order.id is '主键ID';
comment on column esim_order.partner_id is '关联ID 合作伙伴ID';
comment on column esim_order.order_code is '订单编码';
comment on column esim_order.transaction_id is '客户交易ID';
comment on column esim_order.product_type is '产品类型：PACKAGE=套餐，TOP_UP=加油包';
comment on column esim_order.currency is '币种';
comment on column esim_order.amount is '订单金额';
comment on column esim_order.quantity is '购买数量';
comment on column esim_order.iccids is 'ICCID列表';
comment on column esim_order.status is '订单状态';
comment on column esim_order.delete_flag is '删除标记：1=已删除，0=未删除';
comment on column esim_order.delete_time is '删除时间';
comment on column esim_order.create_time is '创建时间';
comment on column esim_order.update_time is '修改时间';

create index if not exists idx_order_partner_create_status
  on esim_order(partner_id, create_time, status);
create index if not exists idx_order_create_status
  on esim_order(create_time, status);

create table if not exists esim_order_unit (
  id                    bigserial primary key,
  order_item_code       varchar(128) not null,
  order_unit_code       varchar(64) not null unique,
  partner_id            bigint not null,
  order_id              bigint not null,
  partner_esim_id       bigint not null,
  provider_id           bigint not null,
  provider_esim_id      bigint not null,
  source_order_unit_id  bigint,
  iccid                 varchar(64) not null,
  use_existing_esim     integer not null,
  provider_order_id     varchar(128),

  quantity              integer not null,
  unit_price            numeric(18, 6) not null,
  product_type          varchar(16) not null,
  product_code          varchar(64) not null,
  cost_billing_mode         varchar(16) not null,
  sale_billing_mode         varchar(16) not null,
  payment_required          integer not null default 0,
  data                  bigint,
  data_unit             varchar(16),
  data_raw              bigint,
  data_unit_raw         varchar(16),
  total_data            numeric(18, 6),
  total_used_data       numeric(18, 6),
  balance_data          numeric(18, 6),
  usage_data_unit       varchar(16),
  active_time           timestamp,
  expire_time           timestamp,
  product_status        varchar(32) not null,
  extra_params          text,

  currency              varchar(8) not null,
  status                varchar(16) not null,
  version               integer not null default 0,
  retry_count           integer not null default 0,
  max_retry_count       integer not null default 3,
  error_message         text,
  return_expired_time   timestamp,
  deliver_expired_time  timestamp,
  delivery_time         timestamp,
  receive_time          timestamp,
  refund_time           timestamp,
  create_time           timestamp not null default now(),
  update_time           timestamp not null default now()
);

create index if not exists idx_order_unit_iccid
  on esim_order_unit(iccid);

create index if not exists idx_order_unit_order_id
  on esim_order_unit(order_id);

create index if not exists idx_order_unit_source_order_unit_id
  on esim_order_unit(source_order_unit_id);

create index if not exists idx_order_unit_provider_order
  on esim_order_unit(provider_id, provider_order_id);

create index if not exists idx_order_unit_return_expired_time
  on esim_order_unit(return_expired_time);

create index if not exists idx_order_unit_deliver_expired_time
  on esim_order_unit(deliver_expired_time);

comment on column esim_order_unit.usage_data_unit is '套餐/充值/使用/剩余流量单位，默认MB';

comment on column esim_order_unit.total_data is '总流量，单位MB';
comment on column esim_order_unit.total_used_data is '使用总流量，单位MB';
comment on column esim_order_unit.balance_data is '剩余流量，单位MB';
comment on column esim_order_unit.active_time is '生效时间';
comment on column esim_order_unit.expire_time is '过期时间';
comment on column esim_order_unit.product_status is '产品状态，表示套餐或加油包状态';

comment on table esim_order_unit is '订单单元明细';
comment on column esim_order_unit.id is '主键ID';
comment on column esim_order_unit.order_item_code is '订单项编码';
comment on column esim_order_unit.order_unit_code is '订单单元编码';
comment on column esim_order_unit.partner_id is '关联ID 合作伙伴ID';
comment on column esim_order_unit.order_id is '关联ID 订单ID';
comment on column esim_order_unit.partner_esim_id is '关联ID 合作伙伴eSIM ID';
comment on column esim_order_unit.provider_id is '关联ID 供应商ID';
comment on column esim_order_unit.provider_esim_id is '关联ID 供应商eSIM ID';
comment on column esim_order_unit.iccid is 'ICCID';
comment on column esim_order_unit.use_existing_esim is '是否使用已有eSIM';
comment on column esim_order_unit.provider_order_id is '供应商订单ID';
comment on column esim_order_unit.source_order_unit_id is '关联ID 加油包所属套餐订单单元ID';
comment on column esim_order_unit.quantity is '购买数量';
comment on column esim_order_unit.unit_price is '订单单元单价';
comment on column esim_order_unit.cost_billing_mode is '成本计费模式：PACKAGE=按套餐，PER_GB=按GB';
comment on column esim_order_unit.sale_billing_mode is '客户计费模式：PACKAGE=按套餐，PER_GB=按GB';
comment on column esim_order_unit.product_type is '产品类型：PACKAGE=套餐，TOP_UP=加油包';
comment on column esim_order_unit.product_code is '产品编码';
comment on column esim_order_unit.data is '流量值';
comment on column esim_order_unit.data_unit is '流量单位';
comment on column esim_order_unit.data_raw is '原始流量值';
comment on column esim_order_unit.data_unit_raw is '原始流量单位';
comment on column esim_order_unit.extra_params is '额外参数，JSON字符串';
comment on column esim_order_unit.currency is '币种';
comment on column esim_order_unit.status is '交易状态';
comment on column esim_order_unit.version is '版本';
comment on column esim_order_unit.retry_count is '已重试次数';
comment on column esim_order_unit.max_retry_count is '最大重试次数';
comment on column esim_order_unit.error_message is '错误消息';
comment on column esim_order_unit.return_expired_time is '退货超时时间';
comment on column esim_order_unit.deliver_expired_time is '发货超时时间';
comment on column esim_order_unit.delivery_time is '发货时间';
comment on column esim_order_unit.receive_time is '收货时间';
comment on column esim_order_unit.refund_time is '退款时间';
comment on column esim_order_unit.create_time is '创建时间';
comment on column esim_order_unit.update_time is '更新时间';
comment on column esim_order_unit.payment_required is '是否需要支付处理：1=需要，0=不需要，下单时根据客户计费模式确定';

create table if not exists esim_order_usage (
  id                     bigserial primary key,
  partner_id             bigint not null,
  provider_id            bigint not null,
  provider_operator_id   bigint not null,
  provider_esim_id       bigint not null,
  order_id               bigint not null,
  order_unit_id          bigint not null,
  iccid                  varchar(64) not null,
  date                   varchar(32) not null,
  provider_operator_code varchar(64) not null,
  mcc                    varchar(8),
  mnc                    varchar(8),
  data_usage             numeric(18, 6) not null default 0,
  data_unit              varchar(16) not null,
  create_time            timestamp not null default now(),
  update_time            timestamp not null default now(),
  unique(provider_id, provider_operator_id, date)
);

comment on table esim_order_usage is '流量用量表';
comment on column esim_order_usage.id is '主键ID';
comment on column esim_order_usage.partner_id is '关联ID 合作伙伴ID';
comment on column esim_order_usage.provider_id is '关联ID 供应商ID';
comment on column esim_order_usage.provider_operator_id is '关联ID 供应商运营商ID';
comment on column esim_order_usage.provider_esim_id is '关联ID 供应商eSIM ID';
comment on column esim_order_usage.order_id is '关联ID 订单ID';
comment on column esim_order_usage.order_unit_id is '关联ID 订单单元ID';
comment on column esim_order_usage.iccid is 'ICCID';
comment on column esim_order_usage.date is '用量日期';
comment on column esim_order_usage.provider_operator_code is '供应商运营商编码';
comment on column esim_order_usage.mcc is 'MCC';
comment on column esim_order_usage.mnc is 'MNC';
comment on column esim_order_usage.data_usage is '使用流量';
comment on column esim_order_usage.data_unit is '流量单位';
comment on column esim_order_usage.create_time is '创建时间';
comment on column esim_order_usage.update_time is '更新时间';

create index if not exists idx_order_usage_iccid_date
  on esim_order_usage(iccid, date);

create index if not exists idx_order_usage_partner_unit_date
  on esim_order_usage(partner_id, order_unit_id, date);

create table if not exists esim_order_price_snapshot (
  id                bigserial primary key,
  type              varchar(16) not null,
  partner_id        bigint not null,
  order_id          bigint not null,
  order_unit_id     bigint not null,
  order_unit_code   varchar(64) not null,
  iccid             varchar(64) not null,
  product_type      varchar(16) not null,
  product_code      varchar(64) not null,

  billing_mode      varchar(16) not null,
  operator_id       bigint not null,
  operator_code     varchar(64) not null,
  price             numeric(18, 6) not null,
  currency          varchar(8) not null,
  country_iso2      varchar(8),
  mcc               varchar(8),
  mnc               varchar(8),
  create_time       timestamp not null default now(),
  unique(partner_id, type, order_unit_id, operator_id)
);

comment on table esim_order_price_snapshot is 'eSIM交易价格快照';
comment on column esim_order_price_snapshot.id is '主键ID';
comment on column esim_order_price_snapshot.type is '快照类型：COST=成本价格，SALE=客户售价';
comment on column esim_order_price_snapshot.partner_id is '关联ID 合作伙伴ID';
comment on column esim_order_price_snapshot.order_id is '关联ID 订单ID';
comment on column esim_order_price_snapshot.order_unit_id is '关联ID 订单单元ID，表示本次eSIM交易';
comment on column esim_order_price_snapshot.order_unit_code is '订单单元编码';
comment on column esim_order_price_snapshot.iccid is 'ICCID';
comment on column esim_order_price_snapshot.product_type is '产品类型：PACKAGE=套餐，TOP_UP=加油包';
comment on column esim_order_price_snapshot.product_code is '产品编码';
comment on column esim_order_price_snapshot.billing_mode is '计费模式：PACKAGE=按套餐，PER_GB=按GB';
comment on column esim_order_price_snapshot.operator_id is '关联ID 运营商ID';
comment on column esim_order_price_snapshot.operator_code is '运营商编码';
comment on column esim_order_price_snapshot.price is '价格';
comment on column esim_order_price_snapshot.currency is '币种';
comment on column esim_order_price_snapshot.country_iso2 is '国家ISO2编码';
comment on column esim_order_price_snapshot.mcc is 'MCC';
comment on column esim_order_price_snapshot.mnc is 'MNC';
comment on column esim_order_price_snapshot.create_time is '创建时间';

create table if not exists esim_partner_esim (
  id                    bigserial primary key,
  partner_id            bigint not null,
  provider_id           bigint not null,
  provider_esim_id      bigint not null,
  iccid                 varchar(64) not null,
  msisdn                varchar(64),
  imsi                  varchar(64),
  eid                   varchar(64),
  smdp_status           varchar(64),
  install_count         integer,
  install_device        varchar(128),
  install_time          timestamp,
  activation_code       text,
  pin                   varchar(12),
  puk                   varchar(12),
  activated_time        timestamp,
  expired_time          timestamp,
  occupancy             int not null default 1,
  status                varchar(16) not null,
  create_time           timestamp not null default now(),
  update_time           timestamp not null default now(),
  unique(partner_id, provider_esim_id)
);

comment on table esim_partner_esim is '合作伙伴eSIM实例';
comment on column esim_partner_esim.id is '主键ID';
comment on column esim_partner_esim.partner_id is '关联ID 合作伙伴ID';
comment on column esim_partner_esim.provider_id is '关联ID 供应商ID';
comment on column esim_partner_esim.provider_esim_id is '关联ID 供应商eSIM ID';
comment on column esim_partner_esim.iccid is 'ICCID';
comment on column esim_partner_esim.msisdn is 'MSISDN';
comment on column esim_partner_esim.imsi is 'IMSI';
comment on column esim_partner_esim.eid is 'EID';
comment on column esim_partner_esim.smdp_status is 'SMDP状态';
comment on column esim_partner_esim.install_count is '安装次数';
comment on column esim_partner_esim.install_device is '安装设备';
comment on column esim_partner_esim.install_time is '安装时间';
comment on column esim_partner_esim.activation_code is '激活码';
comment on column esim_partner_esim.pin is 'PIN码';
comment on column esim_partner_esim.puk is 'PUK码';
comment on column esim_partner_esim.activated_time is '激活时间';
comment on column esim_partner_esim.expired_time is '过期时间';
comment on column esim_partner_esim.occupancy is '占用标记：1=占用，0=未占用';
comment on column esim_partner_esim.status is '状态';
comment on column esim_partner_esim.create_time is '创建时间';
comment on column esim_partner_esim.update_time is '更新时间';

create index if not exists idx_partner_esim_provider_esim_id
  on esim_partner_esim(provider_esim_id);

create table if not exists esim_resource_lock (
  id                    bigserial primary key,
  type                  varchar(16) not null,
  resource_id           varchar(64) not null,
  lock_token            varchar(64) not null,
  description           varchar(128),
  expire_time           timestamp not null,
  unique(type, resource_id)
);

comment on table esim_resource_lock is '通用资源预占锁';
comment on column esim_resource_lock.id is '主键ID';
comment on column esim_resource_lock.type is '资源类型，例如PROVIDER_ESIM=供应商eSIM资源';
comment on column esim_resource_lock.resource_id is '资源ID，同一资源类型下唯一';
comment on column esim_resource_lock.lock_token is '锁令牌，用于续期和释放时校验锁归属';
comment on column esim_resource_lock.description is '锁说明';
comment on column esim_resource_lock.expire_time is '预占过期时间';

create table if not exists esim_balance_account (
  id                 bigserial primary key,
  owner_type         varchar(32) not null,
  owner_id           bigint not null,
  currency           varchar(8) not null,
  available_amount   numeric(18, 6) not null default 0,
  frozen_amount      numeric(18, 6) not null default 0,
  credit_limit       numeric(18, 6),
  status             varchar(16) not null default 'ACTIVE',
  create_time        timestamp not null default now(),
  update_time        timestamp not null default now(),
  unique(owner_type, owner_id, currency)
);

comment on table esim_balance_account is '余额账户';
comment on column esim_balance_account.id is '主键ID';
comment on column esim_balance_account.owner_type is '账户归属类型：PARTNER等';
comment on column esim_balance_account.owner_id is '账户归属ID';
comment on column esim_balance_account.currency is '币种';
comment on column esim_balance_account.available_amount is '可用余额';
comment on column esim_balance_account.frozen_amount is '冻结余额';
comment on column esim_balance_account.status is '状态：ACTIVE=启用，FROZEN=冻结';
comment on column esim_balance_account.create_time is '创建时间';
comment on column esim_balance_account.update_time is '更新时间';
comment on column esim_balance_account.credit_limit is '信用额度，允许余额透支的最大额度，null表示不限额度';

create table if not exists esim_balance_transaction (
  id                         bigserial primary key,
  account_id                 bigint not null,
  owner_type                 varchar(32) not null,
  owner_id                   bigint not null,
  currency                   varchar(8) not null,
  transaction_no             varchar(64) not null unique,
  related_transaction_no     varchar(64),
  biz_type                   varchar(32) not null,
  biz_no                     varchar(128) not null,
  transaction_type           varchar(32) not null,
  direction                  varchar(8) not null,
  amount                     numeric(18, 6) not null,
  available_before           numeric(18, 6) not null,
  available_after            numeric(18, 6) not null,
  frozen_before              numeric(18, 6) not null,
  frozen_after               numeric(18, 6) not null,
  remark                     text,
  create_time                timestamp not null default now()
);

create index if not exists idx_balance_tx_account_time
  on esim_balance_transaction(account_id, create_time);

create index if not exists idx_balance_tx_owner_time
  on esim_balance_transaction(owner_type, owner_id, create_time);

create index if not exists idx_balance_tx_related_transaction_no
  on esim_balance_transaction(related_transaction_no);

create unique index if not exists uk_balance_tx_biz_no_type
  on esim_balance_transaction(biz_type, biz_no, transaction_type);

comment on table esim_balance_transaction is '余额流水';
comment on column esim_balance_transaction.id is '主键ID';
comment on column esim_balance_transaction.account_id is '关联ID 余额账户ID';
comment on column esim_balance_transaction.owner_type is '账户归属类型';
comment on column esim_balance_transaction.owner_id is '账户归属ID';
comment on column esim_balance_transaction.currency is '币种';
comment on column esim_balance_transaction.transaction_no is '余额流水号';
comment on column esim_balance_transaction.related_transaction_no is '关联流水号，用于解冻/确认扣款关联冻结流水';
comment on column esim_balance_transaction.biz_type is '业务类型：ORDER_UNIT、BALANCE_ACCOUNT等';
comment on column esim_balance_transaction.biz_no is '业务编号';
comment on column esim_balance_transaction.transaction_type is '流水类型：RECHARGE、DEDUCT、FREEZE、CONFIRM_PAY、UNFREEZE、REFUND';
comment on column esim_balance_transaction.direction is '方向：IN、OUT、NONE';
comment on column esim_balance_transaction.amount is '变动金额';
comment on column esim_balance_transaction.available_before is '变动前可用余额';
comment on column esim_balance_transaction.available_after is '变动后可用余额';
comment on column esim_balance_transaction.frozen_before is '变动前冻结余额';
comment on column esim_balance_transaction.frozen_after is '变动后冻结余额';
comment on column esim_balance_transaction.remark is '备注';
comment on column esim_balance_transaction.create_time is '创建时间';

create table if not exists mq_message (
  id              bigserial primary key,
  topic           varchar(128) not null,
  partition_no    integer not null,
  message_key     varchar(128),
  payload         text not null,
  headers         text,
  create_time     timestamp not null default now()
);

comment on table mq_message is '数据库消息队列消息日志';
comment on column mq_message.id is '消息偏移ID';
comment on column mq_message.topic is '主题';
comment on column mq_message.partition_no is '分区号';
comment on column mq_message.message_key is '消息Key，用于分区路由和业务幂等';
comment on column mq_message.payload is '消息体文本';
comment on column mq_message.headers is '消息头文本';
comment on column mq_message.create_time is '创建时间';

create index if not exists idx_mq_message_poll
  on mq_message(topic, partition_no, id);

create table if not exists mq_group_offset (
  topic           varchar(128) not null,
  consumer_group  varchar(128) not null,
  partition_no    integer not null,
  offset_id       bigint not null default 0,
  create_time     timestamp not null default now(),
  update_time     timestamp not null default now(),
  primary key(topic, consumer_group, partition_no)
);

comment on table mq_group_offset is '数据库消息队列消费组偏移';
comment on column mq_group_offset.topic is '主题';
comment on column mq_group_offset.consumer_group is '消费组';
comment on column mq_group_offset.partition_no is '分区号';
comment on column mq_group_offset.offset_id is '已确认的最大连续消息偏移ID';
comment on column mq_group_offset.create_time is '创建时间';
comment on column mq_group_offset.update_time is '更新时间';

create table if not exists mq_partition_lease (
  topic           varchar(128) not null,
  consumer_group  varchar(128) not null,
  partition_no    integer not null,
  owner_id        varchar(128) not null,
  lease_until     timestamp not null,
  create_time     timestamp not null,
  update_time     timestamp not null,
  primary key(topic, consumer_group, partition_no)
);

comment on table mq_partition_lease is '数据库消息队列分区消费租约';
comment on column mq_partition_lease.topic is '主题';
comment on column mq_partition_lease.consumer_group is '消费组';
comment on column mq_partition_lease.partition_no is '分区号';
comment on column mq_partition_lease.owner_id is '租约持有者';
comment on column mq_partition_lease.lease_until is '租约过期时间';
comment on column mq_partition_lease.create_time is '创建时间';
comment on column mq_partition_lease.update_time is '更新时间';

create index if not exists idx_mq_partition_lease_until
  on mq_partition_lease(lease_until);

create table if not exists esim_notice_message (
  id                    bigserial primary key,
  receiver_type         varchar(32) not null,
  receiver_id           varchar(64) not null,
  notice_id             varchar(64) not null,
  notice_type           varchar(64) not null,
  notice_time           timestamp,
  payload               text not null,
  webhook_url           text,
  status                varchar(16) not null default 'PENDING',
  retry_count           integer not null default 0,
  max_retry_count       integer not null default 3,
  next_retry_time       timestamp not null default now(),
  last_send_time        timestamp,
  success_time          timestamp,
  response_status       integer,
  error_message         text,
  create_time           timestamp not null default now(),
  update_time           timestamp not null default now(),
  unique(receiver_type, receiver_id, notice_id)
);

comment on table esim_notice_message is '客户通知消息';
comment on column esim_notice_message.id is '主键ID';
comment on column esim_notice_message.receiver_type is '接收方类型';
comment on column esim_notice_message.receiver_id is '接收方ID';
comment on column esim_notice_message.notice_id is '通知唯一ID';
comment on column esim_notice_message.notice_type is '通知类型';
comment on column esim_notice_message.notice_time is '通知事件时间';
comment on column esim_notice_message.payload is '通知消息体文本';
comment on column esim_notice_message.webhook_url is '发送目标Webhook地址';
comment on column esim_notice_message.status is '发送状态：PENDING=待发送，SENDING=发送中，SUCCESS=成功，FAILED=失败，DEAD=终止重试';
comment on column esim_notice_message.retry_count is '已重试次数';
comment on column esim_notice_message.max_retry_count is '最大重试次数';
comment on column esim_notice_message.next_retry_time is '下一次重试时间';
comment on column esim_notice_message.last_send_time is '最近发送时间';
comment on column esim_notice_message.success_time is '发送成功时间';
comment on column esim_notice_message.response_status is '最近响应状态码';
comment on column esim_notice_message.error_message is '最近错误信息';
comment on column esim_notice_message.create_time is '创建时间';
comment on column esim_notice_message.update_time is '更新时间';

create index if not exists idx_notice_message_retry
  on esim_notice_message(status, next_retry_time);

create index if not exists idx_notice_message_receiver
  on esim_notice_message(receiver_type, receiver_id, create_time);
