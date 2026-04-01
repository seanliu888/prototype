begin;

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
comment on table esim_provider_sync is '供应商同步';
comment on column esim_provider_sync.id is '主键ID';
comment on column esim_provider_sync.provider_id is '关联ID 供应商ID';
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
  name          varchar(128),
  create_time   timestamp not null default now(),
  update_time   timestamp not null default now(),
  unique(provider_id, code_raw)
);
comment on table esim_provider_operator is '供应商运营商字典';
comment on column esim_provider_operator.id is '主键ID';
comment on column esim_provider_operator.provider_id is '关联ID，供应商ID';
comment on column esim_provider_operator.code_raw is '业务编码，运营商原始编码';
comment on column esim_provider_operator.code is '业务编码，运营商标准编码';
comment on column esim_provider_operator.name is '运营商展示名称';
comment on column esim_provider_operator.create_time is '创建时间';
comment on column esim_provider_operator.update_time is '更新时间';

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
comment on column esim_provider_esim.status is '库存状态：AVAILABLE=可用，ALLOCATED=已分配，ACTIVATED=已激活，EXPIRED=已过期，SUSPENDED=已暂停';
comment on column esim_provider_esim.allocated_time is '分配时间';
comment on column esim_provider_esim.activated_time is '激活时间';
comment on column esim_provider_esim.expired_time is '过期时间';
comment on column esim_provider_esim.last_sync_time is '最近同步时间';
comment on column esim_provider_esim.create_time is '创建时间';
comment on column esim_provider_esim.update_time is '更新时间';

create index if not exists idx_provider_esim_status
  on esim_provider_esim(provider_id, status);

create table if not exists esim_provider_webhook_event (
  id                bigserial primary key,
  provider_id       bigint not null,
  event_id          varchar(128) not null,
  event_type        varchar(64) not null,
  resource_type     varchar(32),
  resource_key      varchar(128),
  payload           jsonb not null,
  process_status    varchar(16) not null default 'PENDING',
  received_time       timestamp not null default now(),
  processed_time      timestamp,
  unique(provider_id, event_id)
);
comment on table esim_provider_webhook_event is '供应商Webhook事件';
comment on column esim_provider_webhook_event.id is '主键ID';
comment on column esim_provider_webhook_event.provider_id is '关联ID 供应商ID';
comment on column esim_provider_webhook_event.event_id is '关联ID 事件唯一ID';
comment on column esim_provider_webhook_event.event_type is '事件类型';
comment on column esim_provider_webhook_event.resource_type is '资源类型';
comment on column esim_provider_webhook_event.resource_key is '资源标识';
comment on column esim_provider_webhook_event.payload is '事件或请求载荷(JSON)';
comment on column esim_provider_webhook_event.process_status is '处理状态：PENDING=待处理，DONE=已完成，FAILED=失败，IGNORED=忽略';
comment on column esim_provider_webhook_event.received_time is '接收时间';
comment on column esim_provider_webhook_event.processed_time is '处理时间';

create table if not exists esim_partner (
  id             bigserial primary key,
  code           varchar(64) not null unique,
  name           varchar(128) not null,
  region         varchar(64),
  contact_name   varchar(64) not null,
  email          varchar(128) not null,
  phone          varchar(32) not null,
  status         varchar(16) not null,
  billing_mode   varchar(16) not null,
  settlement_mode varchar(16) not null,
  credit_limit   numeric(18, 6),
  balance        numeric(18, 6) not null default 0,
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
comment on column esim_partner.credit_limit is '信用额度';
comment on column esim_partner.balance is '当前余额';
comment on column esim_partner.guide_plan_id is '关联ID 导购价模板ID';
comment on column esim_partner.remark is '备注';
comment on column esim_partner.search_text is '搜索文本';
comment on column esim_partner.create_time is '创建时间';
comment on column esim_partner.update_time is '更新时间';

create index if not exists idx_partner_status on esim_partner(status);

create table if not exists esim_partner_api_config (
  partner_id         bigint primary key,
  access_code        varchar(128) not null unique,
  secret_key_enc     text not null,
  api_status         varchar(16) not null,
  webhook_url        text,
  webhook_enabled    boolean not null default false,
  ip_whitelist       jsonb not null default '[]'::jsonb,
  version            integer not null default 1,
  update_time         timestamp not null default now()
);
comment on table esim_partner_api_config is '合作方API配置';
comment on column esim_partner_api_config.partner_id is '关联ID 合作方ID';
comment on column esim_partner_api_config.access_code is '业务编码 访问凭证';
comment on column esim_partner_api_config.secret_key_enc is '加密密钥';
comment on column esim_partner_api_config.api_status is 'API状态：ENABLED=启用，DISABLED=禁用';
comment on column esim_partner_api_config.webhook_url is 'Webhook地址';
comment on column esim_partner_api_config.webhook_enabled is '是否启用Webhook';
comment on column esim_partner_api_config.ip_whitelist is 'IP白名单(JSON数组)';
comment on column esim_partner_api_config.version is '配置版本号';
comment on column esim_partner_api_config.update_time is '更新时间';

create table if not exists esim_partner_webhook_delivery (
  id                bigserial primary key,
  partner_id        bigint not null,
  event_type        varchar(64) not null,
  event_key         varchar(128),
  target_url        text not null,
  request_body      jsonb not null,
  http_status       integer,
  delivery_status   varchar(16) not null,
  retry_count       integer not null default 0,
  next_retry_time     timestamp,
  last_error        text,
  create_time        timestamp not null default now()
);
comment on table esim_partner_webhook_delivery is '合作方Webhook投递记录';
comment on column esim_partner_webhook_delivery.id is '主键ID';
comment on column esim_partner_webhook_delivery.partner_id is '关联ID 合作方ID';
comment on column esim_partner_webhook_delivery.event_type is '事件类型';
comment on column esim_partner_webhook_delivery.event_key is '事件业务键';
comment on column esim_partner_webhook_delivery.target_url is '目标回调地址';
comment on column esim_partner_webhook_delivery.request_body is '请求体(JSON)';
comment on column esim_partner_webhook_delivery.http_status is '状态 HTTP状态码';
comment on column esim_partner_webhook_delivery.delivery_status is '投递状态：PENDING=待投递，SUCCESS=成功，FAILED=失败';
comment on column esim_partner_webhook_delivery.retry_count is '重试次数';
comment on column esim_partner_webhook_delivery.next_retry_time is '下次重试时间';
comment on column esim_partner_webhook_delivery.last_error is '最后一次错误信息';
comment on column esim_partner_webhook_delivery.create_time is '创建时间';

create index if not exists idx_webhook_delivery_partner
  on esim_partner_webhook_delivery(partner_id, create_time desc);

create table if not exists esim_package (
  id                   bigserial primary key,
  code                 varchar(64) not null unique,
  provider_id          bigint not null,
  code_raw     varchar(128) not null,
  name_raw             varchar(256),
  name                 varchar(256) not null,
  type                 varchar(16) not null,
  coverage             jsonb,
  operator_code        varchar(64),
  mcc                  varchar(8),
  mnc                  varchar(8),
  data                 bigint,
  data_unit            varchar(16),
  duration             integer,
  duration_unit        varchar(16),
  speed                varchar(16),
  billing_mode         varchar(16) not null,
  currency             varchar(8) not null,
  price                numeric(18, 6) not null,
  status               varchar(16) not null,
  last_sync_time         timestamp,
  create_time           timestamp not null default now(),
  update_time           timestamp not null default now(),
  unique(provider_id, code_raw)
);
comment on table esim_package is '套餐目录';
comment on column esim_package.id is '主键ID';
comment on column esim_package.code is '业务编码 套餐编码';
comment on column esim_package.provider_id is '关联ID 供应商ID';
comment on column esim_package.code_raw is '关联ID 供应商原始套餐ID';
comment on column esim_package.name_raw is '供应商原始套餐名称';
comment on column esim_package.name is '名称 套餐名称';
comment on column esim_package.type is '套餐类型：COUNTRY=国家包，REGION=区域包，GLOBAL=全球包';
comment on column esim_package.coverage is '覆盖范围(JSON)';
comment on column esim_package.operator_code is '业务编码 运营商编码';
comment on column esim_package.mcc is 'MCC';
comment on column esim_package.mnc is 'MNC';
comment on column esim_package.data is '流量';
comment on column esim_package.data_unit is '流量单位：MB=兆，GB=千兆';
comment on column esim_package.duration is '周期数值';
comment on column esim_package.duration_unit is '周期单位：24HOURS=24小时，DAY=日，MONTH=月';
comment on column esim_package.speed is '速率等级';
comment on column esim_package.billing_mode is '计费模式：PACKAGE=按套餐，PER_GB=按GB';
comment on column esim_package.currency is '币种';
comment on column esim_package.price is '价格';
comment on column esim_package.status is '状态：ON_SALE=在售，OFF_SALE=停售';
comment on column esim_package.last_sync_time is '最近同步时间';
comment on column esim_package.create_time is '创建时间';
comment on column esim_package.update_time is '更新时间';

create index if not exists idx_package_provider on esim_package(provider_id, status);
create index if not exists idx_package_coverage on esim_package using gin(coverage);

create table if not exists esim_product_refill (
  id                bigserial primary key,
  package_id        bigint not null,
  refill_code       varchar(64) not null,
  refill_name       varchar(128),
  traffic_mb        integer not null,
  currency          varchar(8) not null,
  price             numeric(18, 6) not null,
  status            varchar(16) not null,
  last_sync_time      timestamp,
  create_time        timestamp not null default now(),
  update_time        timestamp not null default now(),
  unique(package_id, refill_code)
);
comment on table esim_product_refill is '加油包目录';
comment on column esim_product_refill.id is '主键ID';
comment on column esim_product_refill.package_id is '关联ID 套餐ID';
comment on column esim_product_refill.refill_code is '业务编码';
comment on column esim_product_refill.refill_name is '名称';
comment on column esim_product_refill.traffic_mb is '流量(MB)';
comment on column esim_product_refill.currency is '币种';
comment on column esim_product_refill.price is '价格';
comment on column esim_product_refill.status is '状态：ON_SALE=在售，OFF_SALE=下架';
comment on column esim_product_refill.last_sync_time is '最近同步时间';
comment on column esim_product_refill.create_time is '创建时间';
comment on column esim_product_refill.update_time is '更新时间';

create table if not exists esim_guide_price_plan (
  id                bigserial primary key,
  plan_code         varchar(64) not null unique,
  plan_name         varchar(128) not null,
  is_system_default boolean not null default false,
  status            varchar(16) not null,
  remark            text,
  create_time        timestamp not null default now(),
  update_time        timestamp not null default now()
);
comment on table esim_guide_price_plan is '指导价模板';
comment on column esim_guide_price_plan.id is '主键ID';
comment on column esim_guide_price_plan.plan_code is '业务编码 模板编码';
comment on column esim_guide_price_plan.plan_name is '名称 模板名称';
comment on column esim_guide_price_plan.is_system_default is '是否系统默认模板';
comment on column esim_guide_price_plan.status is '状态：ENABLED=启用，DISABLED=禁用';
comment on column esim_guide_price_plan.remark is '备注';
comment on column esim_guide_price_plan.create_time is '创建时间';
comment on column esim_guide_price_plan.update_time is '更新时间';

create table if not exists esim_price_item (
  id                bigserial primary key,
  price_scope       varchar(16) not null,
  owner_id          bigint not null,
  product_type      varchar(16) not null,
  product_id        bigint not null,
  currency          varchar(8) not null,
  cost_price        numeric(18, 6),
  sale_price        numeric(18, 6) not null,
  retail_price      numeric(18, 6),
  sale_status       varchar(16) not null,
  create_time        timestamp not null default now(),
  update_time        timestamp not null default now(),
  unique(price_scope, owner_id, product_type, product_id)
);
comment on table esim_price_item is '价格明细';
comment on column esim_price_item.id is '主键ID';
comment on column esim_price_item.price_scope is '价格范围：GUIDE=指导价，SPECIAL=特殊价';
comment on column esim_price_item.owner_id is '关联ID 归属对象ID(按price_scope解释)';
comment on column esim_price_item.product_type is '产品类型：PACKAGE=套餐，REFILL=加油包';
comment on column esim_price_item.product_id is '关联ID 产品ID(按product_type解释)';
comment on column esim_price_item.currency is '币种';
comment on column esim_price_item.cost_price is '成本价';
comment on column esim_price_item.sale_price is '销售价';
comment on column esim_price_item.retail_price is '建议零售价';
comment on column esim_price_item.sale_status is '售卖状态：ON_SALE=在售，OFF_SALE=下架';
comment on column esim_price_item.create_time is '创建时间';
comment on column esim_price_item.update_time is '更新时间';

create index if not exists idx_price_item_lookup
  on esim_price_item(product_type, product_id, price_scope, owner_id);

create table if not exists esim_price_effective_cache (
  partner_id          bigint not null,
  product_type        varchar(16) not null,
  product_id          bigint not null,
  final_cost_price    numeric(18, 6),
  final_sale_price    numeric(18, 6) not null,
  final_retail_price  numeric(18, 6),
  final_sale_status   varchar(16) not null,
  price_source        varchar(16) not null,
  source_id           bigint not null,
  refreshed_time        timestamp not null default now(),
  primary key (partner_id, product_type, product_id)
);
comment on table esim_price_effective_cache is '生效价格缓存';
comment on column esim_price_effective_cache.partner_id is '关联ID 合作方ID';
comment on column esim_price_effective_cache.product_type is '产品类型：PACKAGE=套餐，REFILL=加油包';
comment on column esim_price_effective_cache.product_id is '关联ID 产品ID(按product_type解释)';
comment on column esim_price_effective_cache.final_cost_price is '生效成本价';
comment on column esim_price_effective_cache.final_sale_price is '生效销售价';
comment on column esim_price_effective_cache.final_retail_price is '生效建议零售价';
comment on column esim_price_effective_cache.final_sale_status is '生效售卖状态：ON_SALE=在售，OFF_SALE=下架';
comment on column esim_price_effective_cache.price_source is '价格来源：SPECIAL=特殊价，GUIDE=指导价';
comment on column esim_price_effective_cache.source_id is '关联ID 来源记录ID';
comment on column esim_price_effective_cache.refreshed_time is '缓存刷新时间';

create index if not exists idx_price_effective_status
  on esim_price_effective_cache(partner_id, final_sale_status);

create table if not exists esim_order_main (
  id                 bigserial primary key,
  order_no           varchar(64) not null unique,
  merchant_order_no  varchar(64) not null,
  partner_id         bigint not null,
  provider_id        bigint not null,
  supplier_txn_no    varchar(64),
  order_type         varchar(16) not null,
  currency           varchar(8) not null,
  amount             numeric(18, 6) not null,
  esim_qty           integer not null default 0,
  order_status       varchar(16) not null,
  create_time         timestamp not null default now(),
  paid_time            timestamp,
  unique(partner_id, merchant_order_no)
);
comment on table esim_order_main is '订单主表';
comment on column esim_order_main.id is '主键ID';
comment on column esim_order_main.order_no is '平台订单号';
comment on column esim_order_main.merchant_order_no is '商户订单号';
comment on column esim_order_main.partner_id is '关联ID 合作方ID';
comment on column esim_order_main.provider_id is '关联ID 供应商ID';
comment on column esim_order_main.supplier_txn_no is '上游交易号';
comment on column esim_order_main.order_type is '订单类型：PACKAGE=套餐下单，TOPUP=流量充值';
comment on column esim_order_main.currency is '币种';
comment on column esim_order_main.amount is '订单金额';
comment on column esim_order_main.esim_qty is 'eSIM数量';
comment on column esim_order_main.order_status is '订单状态：CREATED=已创建，PAID=已支付，DELIVERED=已发货，ACTIVATING=激活中，ACTIVATED=已激活，CANCELLED=已取消，FAILED=失败';
comment on column esim_order_main.create_time is '创建时间';
comment on column esim_order_main.paid_time is '支付时间';

create index if not exists idx_order_main_partner_time
  on esim_order_main(partner_id, create_time desc);
create index if not exists idx_order_main_status_time
  on esim_order_main(order_status, create_time desc);

create table if not exists esim_order_item (
  id                bigserial primary key,
  order_id          bigint not null,
  item_type         varchar(16) not null,
  package_id        bigint,
  refill_id         bigint,
  qty               integer not null,
  unit_price        numeric(18, 6) not null,
  amount            numeric(18, 6) not null
);
comment on table esim_order_item is '订单明细';
comment on column esim_order_item.id is '主键ID';
comment on column esim_order_item.order_id is '关联ID 订单ID';
comment on column esim_order_item.item_type is '明细类型：PACKAGE=套餐，REFILL=加油包';
comment on column esim_order_item.package_id is '关联ID 套餐ID';
comment on column esim_order_item.refill_id is '关联ID 加油包ID';
comment on column esim_order_item.qty is '数量';
comment on column esim_order_item.unit_price is '单价';
comment on column esim_order_item.amount is '明细金额';

create index if not exists idx_order_item_order on esim_order_item(order_id);

create table if not exists esim_esim_profile (
  id                     bigserial primary key,
  iccid                  varchar(32) not null unique,
  imsi                   varchar(32),
  eid                    varchar(64),
  order_id               bigint,
  order_item_id          bigint,
  partner_id             bigint not null,
  provider_id            bigint not null,
  package_id             bigint,
  profile_status         varchar(16) not null,
  device_info            varchar(128),
  activation_code_masked varchar(128),
  qr_code_url            text,
  activated_time           timestamp,
  expired_time             timestamp,
  create_time             timestamp not null default now(),
  update_time             timestamp not null default now()
);
comment on table esim_esim_profile is 'eSIM档案';
comment on column esim_esim_profile.id is '主键ID';
comment on column esim_esim_profile.iccid is 'ICCID';
comment on column esim_esim_profile.imsi is 'IMSI';
comment on column esim_esim_profile.eid is 'EID';
comment on column esim_esim_profile.order_id is '关联ID 订单ID';
comment on column esim_esim_profile.order_item_id is '关联ID 订单明细ID';
comment on column esim_esim_profile.partner_id is '关联ID 合作方ID';
comment on column esim_esim_profile.provider_id is '关联ID 供应商ID';
comment on column esim_esim_profile.package_id is '关联ID 套餐ID';
comment on column esim_esim_profile.profile_status is 'Profile状态：PENDING=待激活，ACTIVATED=已激活，EXPIRED=已过期，SUSPENDED=已暂停，DISABLED=已禁用';
comment on column esim_esim_profile.device_info is '设备信息';
comment on column esim_esim_profile.activation_code_masked is '脱敏激活码';
comment on column esim_esim_profile.qr_code_url is '二维码地址';
comment on column esim_esim_profile.activated_time is '激活时间';
comment on column esim_esim_profile.expired_time is '过期时间';
comment on column esim_esim_profile.create_time is '创建时间';
comment on column esim_esim_profile.update_time is '更新时间';

create index if not exists idx_esim_profile_partner_status
  on esim_esim_profile(partner_id, profile_status);

create table if not exists esim_esim_usage_snapshot (
  id                bigserial primary key,
  esim_id           bigint not null,
  used_mb           numeric(18, 6) not null,
  remain_mb         numeric(18, 6) not null,
  remain_days       integer,
  snapshot_time       timestamp not null default now()
);
comment on table esim_esim_usage_snapshot is 'eSIM用量快照';
comment on column esim_esim_usage_snapshot.id is '主键ID';
comment on column esim_esim_usage_snapshot.esim_id is '关联ID eSIM实例ID';
comment on column esim_esim_usage_snapshot.used_mb is '已用流量(MB)';
comment on column esim_esim_usage_snapshot.remain_mb is '剩余流量(MB)';
comment on column esim_esim_usage_snapshot.remain_days is '剩余天数';
comment on column esim_esim_usage_snapshot.snapshot_time is '快照时间';

create index if not exists idx_esim_usage_snapshot_time
  on esim_esim_usage_snapshot(esim_id, snapshot_time desc);

create table if not exists esim_esim_addon_purchase (
  id                bigserial primary key,
  order_id          bigint not null,
  order_item_id     bigint not null,
  esim_id           bigint not null,
  refill_id         bigint not null,
  traffic_mb        integer not null,
  status            varchar(16) not null,
  purchased_time      timestamp not null default now(),
  used_mb           numeric(18, 6) not null default 0,
  unique(order_item_id, esim_id)
);
comment on table esim_esim_addon_purchase is 'eSIM加油包购买记录';
comment on column esim_esim_addon_purchase.id is '主键ID';
comment on column esim_esim_addon_purchase.order_id is '关联ID 订单ID';
comment on column esim_esim_addon_purchase.order_item_id is '关联ID 订单明细ID';
comment on column esim_esim_addon_purchase.esim_id is '关联ID eSIM实例ID';
comment on column esim_esim_addon_purchase.refill_id is '关联ID 加油包ID';
comment on column esim_esim_addon_purchase.traffic_mb is '流量(MB)';
comment on column esim_esim_addon_purchase.status is '状态：ENABLED=生效，UNUSED=未使用，USED_UP=已用完，EXPIRED=已过期，FAILED=失败';
comment on column esim_esim_addon_purchase.purchased_time is '购买时间';
comment on column esim_esim_addon_purchase.used_mb is '已用流量(MB)';

create index if not exists idx_esim_addon_purchase_esim
  on esim_esim_addon_purchase(esim_id, purchased_time desc);

create table if not exists esim_wallet_ledger (
  id                bigserial primary key,
  party_type        varchar(16) not null,
  party_id          bigint not null,
  txn_type          varchar(16) not null,
  currency          varchar(8) not null,
  amount            numeric(18, 6) not null,
  balance_after     numeric(18, 6),
  ref_type          varchar(16),
  ref_id            bigint,
  remark            text,
  create_time        timestamp not null default now()
);
comment on table esim_wallet_ledger is '资金流水';
comment on column esim_wallet_ledger.id is '主键ID';
comment on column esim_wallet_ledger.party_type is '主体类型：PARTNER=合作方，PROVIDER=供应商';
comment on column esim_wallet_ledger.party_id is '关联ID 主体ID';
comment on column esim_wallet_ledger.txn_type is '交易类型：RECHARGE=充值，CONSUME=消费，ADJUST=调账，REFUND=退款，SETTLE=结算';
comment on column esim_wallet_ledger.currency is '币种';
comment on column esim_wallet_ledger.amount is '变动金额';
comment on column esim_wallet_ledger.balance_after is '变动后余额';
comment on column esim_wallet_ledger.ref_type is '关联业务类型';
comment on column esim_wallet_ledger.ref_id is '关联ID 关联业务ID';
comment on column esim_wallet_ledger.remark is '备注';
comment on column esim_wallet_ledger.create_time is '创建时间';

create index if not exists idx_wallet_ledger_party_time
  on esim_wallet_ledger(party_type, party_id, create_time desc);

create table if not exists esim_settlement_batch (
  id                   bigserial primary key,
  party_type           varchar(16) not null,
  party_id             bigint not null,
  settlement_direction varchar(16) not null,
  period_start         date not null,
  period_end           date not null,
  currency             varchar(8) not null,
  total_amount         numeric(18, 6) not null,
  paid_amount          numeric(18, 6) not null default 0,
  unpaid_amount        numeric(18, 6) not null,
  status               varchar(16) not null,
  create_time           timestamp not null default now(),
  confirmed_time         timestamp
);
comment on table esim_settlement_batch is '结算单主表';
comment on column esim_settlement_batch.id is '主键ID';
comment on column esim_settlement_batch.party_type is '主体类型：PARTNER=合作方，PROVIDER=供应商';
comment on column esim_settlement_batch.party_id is '关联ID 主体ID';
comment on column esim_settlement_batch.settlement_direction is '结算方向：RECEIVABLE=应收，PAYABLE=应付';
comment on column esim_settlement_batch.period_start is '账期开始日期';
comment on column esim_settlement_batch.period_end is '账期结束日期';
comment on column esim_settlement_batch.currency is '币种';
comment on column esim_settlement_batch.total_amount is '账期总金额';
comment on column esim_settlement_batch.paid_amount is '已支付金额';
comment on column esim_settlement_batch.unpaid_amount is '未支付金额';
comment on column esim_settlement_batch.status is '状态：DRAFT=草稿，PENDING=待确认，CONFIRMED=已确认，PARTIAL=部分结清，SETTLED=已结清，CANCELLED=已取消';
comment on column esim_settlement_batch.create_time is '创建时间';
comment on column esim_settlement_batch.confirmed_time is '确认时间';

create index if not exists idx_settlement_batch_party_period
  on esim_settlement_batch(party_type, party_id, period_start, period_end);

create table if not exists esim_settlement_item (
  id                bigserial primary key,
  batch_id          bigint not null,
  source_type       varchar(16) not null,
  source_id         bigint not null,
  amount            numeric(18, 6) not null,
  remark            text,
  create_time        timestamp not null default now()
);
comment on table esim_settlement_item is '结算单明细';
comment on column esim_settlement_item.id is '主键ID';
comment on column esim_settlement_item.batch_id is '关联ID';
comment on column esim_settlement_item.source_type is '来源类型：ORDER=订单，REFUND=退款，ADJUST=调账';
comment on column esim_settlement_item.source_id is '关联ID 来源记录ID';
comment on column esim_settlement_item.amount is '结算金额';
comment on column esim_settlement_item.remark is '备注';
comment on column esim_settlement_item.create_time is '创建时间';

create index if not exists idx_settlement_item_batch on esim_settlement_item(batch_id);

commit;







