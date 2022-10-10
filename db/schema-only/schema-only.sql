--
-- PostgreSQL database dump
--

-- Dumped from database version 11.5 (Debian 11.5-3.pgdg90+1)
-- Dumped by pg_dump version 12.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: podcasts_latest_live_item_status_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.podcasts_latest_live_item_status_enum AS ENUM (
    'pending',
    'live',
    'ended',
    'none'
);


ALTER TYPE public.podcasts_latest_live_item_status_enum OWNER TO postgres;

--
-- Name: podcasts_medium_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.podcasts_medium_enum AS ENUM (
    'podcast',
    'music',
    'video',
    'film',
    'audiobook',
    'newsletter',
    'blog',
    'music-video'
);


ALTER TYPE public.podcasts_medium_enum OWNER TO postgres;

SET default_tablespace = '';

--
-- Name: accountClaimToken; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."accountClaimToken" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    claimed boolean DEFAULT false NOT NULL,
    "yearsToAdd" integer DEFAULT 1 NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public."accountClaimToken" OWNER TO postgres;

--
-- Name: appStorePurchase; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."appStorePurchase" (
    "transactionId" character varying NOT NULL,
    cancellation_date character varying,
    cancellation_date_ms character varying,
    cancellation_date_pst character varying,
    cancellation_reason character varying,
    expires_date character varying,
    expires_date_ms character varying,
    expires_date_pst character varying,
    is_in_intro_offer_period boolean,
    is_trial_period boolean,
    original_purchase_date character varying,
    original_purchase_date_ms character varying,
    original_purchase_date_pst character varying,
    original_transaction_id character varying,
    product_id character varying,
    promotional_offer_id character varying,
    purchase_date character varying,
    purchase_date_ms character varying,
    purchase_date_pst character varying,
    quantity integer,
    transaction_id character varying,
    web_order_line_item_id character varying,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    "ownerId" character varying(14) NOT NULL
);


ALTER TABLE public."appStorePurchase" OWNER TO postgres;

--
-- Name: auth_group; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_group (
    id integer NOT NULL,
    name character varying(80) NOT NULL
);


ALTER TABLE public.auth_group OWNER TO postgres;

--
-- Name: auth_group_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.auth_group_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_group_id_seq OWNER TO postgres;

--
-- Name: auth_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.auth_group_id_seq OWNED BY public.auth_group.id;


--
-- Name: auth_group_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_group_permissions (
    id integer NOT NULL,
    group_id integer NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE public.auth_group_permissions OWNER TO postgres;

--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.auth_group_permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_group_permissions_id_seq OWNER TO postgres;

--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.auth_group_permissions_id_seq OWNED BY public.auth_group_permissions.id;


--
-- Name: auth_permission; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_permission (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    content_type_id integer NOT NULL,
    codename character varying(100) NOT NULL
);


ALTER TABLE public.auth_permission OWNER TO postgres;

--
-- Name: auth_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.auth_permission_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_permission_id_seq OWNER TO postgres;

--
-- Name: auth_permission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.auth_permission_id_seq OWNED BY public.auth_permission.id;


--
-- Name: auth_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_user (
    id integer NOT NULL,
    password character varying(128) NOT NULL,
    last_login timestamp with time zone,
    is_superuser boolean NOT NULL,
    username character varying(150) NOT NULL,
    first_name character varying(30) NOT NULL,
    last_name character varying(150) NOT NULL,
    email character varying(254) NOT NULL,
    is_staff boolean NOT NULL,
    is_active boolean NOT NULL,
    date_joined timestamp with time zone NOT NULL
);


ALTER TABLE public.auth_user OWNER TO postgres;

--
-- Name: auth_user_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_user_groups (
    id integer NOT NULL,
    user_id integer NOT NULL,
    group_id integer NOT NULL
);


ALTER TABLE public.auth_user_groups OWNER TO postgres;

--
-- Name: auth_user_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.auth_user_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_user_groups_id_seq OWNER TO postgres;

--
-- Name: auth_user_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.auth_user_groups_id_seq OWNED BY public.auth_user_groups.id;


--
-- Name: auth_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.auth_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_user_id_seq OWNER TO postgres;

--
-- Name: auth_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.auth_user_id_seq OWNED BY public.auth_user.id;


--
-- Name: auth_user_user_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_user_user_permissions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE public.auth_user_user_permissions OWNER TO postgres;

--
-- Name: auth_user_user_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.auth_user_user_permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_user_user_permissions_id_seq OWNER TO postgres;

--
-- Name: auth_user_user_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.auth_user_user_permissions_id_seq OWNED BY public.auth_user_user_permissions.id;


--
-- Name: authors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.authors (
    id character varying(14) DEFAULT 'vt9WpUY77'::character varying NOT NULL,
    name character varying NOT NULL,
    slug character varying NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    int_id integer NOT NULL
);


ALTER TABLE public.authors OWNER TO postgres;

--
-- Name: authors_int_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.authors_int_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.authors_int_id_seq OWNER TO postgres;

--
-- Name: authors_int_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.authors_int_id_seq OWNED BY public.authors.int_id;


--
-- Name: bitpayInvoices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."bitpayInvoices" (
    id character varying NOT NULL,
    "orderId" character varying NOT NULL,
    "amountPaid" integer DEFAULT 0 NOT NULL,
    currency character varying NOT NULL,
    "exceptionStatus" character varying DEFAULT 'false'::character varying NOT NULL,
    price integer NOT NULL,
    status character varying,
    token character varying NOT NULL,
    "transactionCurrency" character varying,
    "transactionSpeed" character varying,
    url character varying NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    "ownerId" character varying(14) NOT NULL
);


ALTER TABLE public."bitpayInvoices" OWNER TO postgres;

--
-- Name: categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categories (
    id character varying(14) DEFAULT 'FeSQ-dcCHv'::character varying NOT NULL,
    "fullPath" character varying NOT NULL,
    slug character varying NOT NULL,
    title character varying NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    "categoryId" character varying(14),
    int_id integer NOT NULL
);


ALTER TABLE public.categories OWNER TO postgres;

--
-- Name: categories_int_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.categories_int_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.categories_int_id_seq OWNER TO postgres;

--
-- Name: categories_int_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.categories_int_id_seq OWNED BY public.categories.int_id;


--
-- Name: django_admin_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_admin_log (
    id integer NOT NULL,
    action_time timestamp with time zone NOT NULL,
    object_id text,
    object_repr character varying(200) NOT NULL,
    action_flag smallint NOT NULL,
    change_message text NOT NULL,
    content_type_id integer,
    user_id integer NOT NULL,
    CONSTRAINT django_admin_log_action_flag_check CHECK ((action_flag >= 0))
);


ALTER TABLE public.django_admin_log OWNER TO postgres;

--
-- Name: django_admin_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.django_admin_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_admin_log_id_seq OWNER TO postgres;

--
-- Name: django_admin_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.django_admin_log_id_seq OWNED BY public.django_admin_log.id;


--
-- Name: django_content_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_content_type (
    id integer NOT NULL,
    app_label character varying(100) NOT NULL,
    model character varying(100) NOT NULL
);


ALTER TABLE public.django_content_type OWNER TO postgres;

--
-- Name: django_content_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.django_content_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_content_type_id_seq OWNER TO postgres;

--
-- Name: django_content_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.django_content_type_id_seq OWNED BY public.django_content_type.id;


--
-- Name: django_mfa_u2fkey; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_mfa_u2fkey (
    id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    last_used_at timestamp with time zone,
    public_key text NOT NULL,
    key_handle text NOT NULL,
    app_id text NOT NULL,
    user_id integer NOT NULL
);


ALTER TABLE public.django_mfa_u2fkey OWNER TO postgres;

--
-- Name: django_mfa_u2fkey_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.django_mfa_u2fkey_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_mfa_u2fkey_id_seq OWNER TO postgres;

--
-- Name: django_mfa_u2fkey_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.django_mfa_u2fkey_id_seq OWNED BY public.django_mfa_u2fkey.id;


--
-- Name: django_mfa_userotp; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_mfa_userotp (
    id integer NOT NULL,
    otp_type character varying(20) NOT NULL,
    secret_key character varying(100) NOT NULL,
    user_id integer NOT NULL
);


ALTER TABLE public.django_mfa_userotp OWNER TO postgres;

--
-- Name: django_mfa_userotp_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.django_mfa_userotp_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_mfa_userotp_id_seq OWNER TO postgres;

--
-- Name: django_mfa_userotp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.django_mfa_userotp_id_seq OWNED BY public.django_mfa_userotp.id;


--
-- Name: django_mfa_userrecoverycodes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_mfa_userrecoverycodes (
    id integer NOT NULL,
    secret_code character varying(10) NOT NULL,
    user_id integer NOT NULL
);


ALTER TABLE public.django_mfa_userrecoverycodes OWNER TO postgres;

--
-- Name: django_mfa_userrecoverycodes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.django_mfa_userrecoverycodes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_mfa_userrecoverycodes_id_seq OWNER TO postgres;

--
-- Name: django_mfa_userrecoverycodes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.django_mfa_userrecoverycodes_id_seq OWNED BY public.django_mfa_userrecoverycodes.id;


--
-- Name: django_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_migrations (
    id integer NOT NULL,
    app character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    applied timestamp with time zone NOT NULL
);


ALTER TABLE public.django_migrations OWNER TO postgres;

--
-- Name: django_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.django_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_migrations_id_seq OWNER TO postgres;

--
-- Name: django_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.django_migrations_id_seq OWNED BY public.django_migrations.id;


--
-- Name: django_session; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_session (
    session_key character varying(40) NOT NULL,
    session_data text NOT NULL,
    expire_date timestamp with time zone NOT NULL
);


ALTER TABLE public.django_session OWNER TO postgres;

--
-- Name: episodes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.episodes (
    id character varying(14) DEFAULT 'ZPHUwch6WM'::character varying NOT NULL,
    description character varying,
    duration integer DEFAULT 0 NOT NULL,
    "episodeType" character varying,
    guid character varying,
    "imageUrl" character varying,
    "isExplicit" boolean DEFAULT false NOT NULL,
    "isPublic" boolean DEFAULT false NOT NULL,
    "linkUrl" character varying,
    "mediaFilesize" integer DEFAULT 0 NOT NULL,
    "mediaType" character varying,
    "mediaUrl" character varying NOT NULL,
    "pastHourTotalUniquePageviews" integer DEFAULT 0 NOT NULL,
    "pastDayTotalUniquePageviews" integer DEFAULT 0 NOT NULL,
    "pastWeekTotalUniquePageviews" integer DEFAULT 0 NOT NULL,
    "pastMonthTotalUniquePageviews" integer DEFAULT 0 NOT NULL,
    "pastYearTotalUniquePageviews" integer DEFAULT 0 NOT NULL,
    "pastAllTimeTotalUniquePageviews" integer DEFAULT 0 NOT NULL,
    "pubDate" timestamp without time zone,
    title character varying,
    "podcastId" character varying NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    "chaptersType" character varying,
    "chaptersUrl" character varying,
    "chaptersUrlLastParsed" timestamp without time zone,
    funding text,
    transcript text,
    value text,
    "credentialsRequired" boolean DEFAULT false NOT NULL,
    "socialInteraction" text,
    "alternateEnclosures" text,
    "contentLinks" text,
    int_id bigint NOT NULL,
    subtitle character varying,
    persons jsonb,
    CONSTRAINT chk CHECK ((int_id IS NOT NULL))
);


ALTER TABLE public.episodes OWNER TO postgres;

--
-- Name: episodes_authors_authors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.episodes_authors_authors (
    "episodesId" character varying(14) NOT NULL,
    "authorsId" character varying(14) NOT NULL
);


ALTER TABLE public.episodes_authors_authors OWNER TO postgres;

--
-- Name: episodes_categories_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.episodes_categories_categories (
    "episodesId" character varying(14) NOT NULL,
    "categoriesId" character varying(14) NOT NULL
);


ALTER TABLE public.episodes_categories_categories OWNER TO postgres;

--
-- Name: episodes_int_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.episodes_int_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.episodes_int_id_seq OWNER TO postgres;

--
-- Name: episodes_int_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.episodes_int_id_seq OWNED BY public.episodes.int_id;


--
-- Name: episodes_most_recent; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.episodes_most_recent AS
 SELECT episodes.id,
    episodes.description,
    episodes.duration,
    episodes."episodeType",
    episodes.guid,
    episodes."imageUrl",
    episodes."isExplicit",
    episodes."isPublic",
    episodes."linkUrl",
    episodes."mediaFilesize",
    episodes."mediaType",
    episodes."mediaUrl",
    episodes."pastHourTotalUniquePageviews",
    episodes."pastDayTotalUniquePageviews",
    episodes."pastWeekTotalUniquePageviews",
    episodes."pastMonthTotalUniquePageviews",
    episodes."pastYearTotalUniquePageviews",
    episodes."pastAllTimeTotalUniquePageviews",
    episodes."pubDate",
    episodes.title,
    episodes."podcastId",
    episodes."createdAt",
    episodes."updatedAt",
    episodes."chaptersType",
    episodes."chaptersUrl",
    episodes."chaptersUrlLastParsed",
    episodes.funding,
    episodes.transcript,
    episodes.value,
    episodes."credentialsRequired",
    episodes."socialInteraction",
    episodes."alternateEnclosures",
    episodes."contentLinks",
    episodes.int_id,
    episodes.subtitle
   FROM public.episodes
  WHERE ((episodes."isPublic" = true) AND (episodes."pubDate" > (now() - '1000 days'::interval)) AND (episodes."pubDate" < (now() + '1 day'::interval)))
  WITH NO DATA;


ALTER TABLE public.episodes_most_recent OWNER TO postgres;

--
-- Name: fcmDevices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."fcmDevices" (
    "fcmToken" character varying NOT NULL,
    "userId" character varying(14),
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public."fcmDevices" OWNER TO postgres;

--
-- Name: feedUrls; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."feedUrls" (
    id character varying(14) DEFAULT 'UeFlQWLqQz'::character varying NOT NULL,
    "isAuthority" boolean,
    url character varying NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    "podcastId" character varying(14),
    int_id integer NOT NULL
);


ALTER TABLE public."feedUrls" OWNER TO postgres;

--
-- Name: feedUrls_int_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."feedUrls_int_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."feedUrls_int_id_seq" OWNER TO postgres;

--
-- Name: feedUrls_int_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."feedUrls_int_id_seq" OWNED BY public."feedUrls".int_id;


--
-- Name: googlePlayPurchase; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."googlePlayPurchase" (
    "transactionId" character varying NOT NULL,
    "acknowledgementState" integer,
    "consumptionState" integer,
    "developerPayload" character varying,
    kind character varying,
    "productId" character varying NOT NULL,
    "purchaseTimeMillis" character varying,
    "purchaseState" integer,
    "purchaseToken" character varying NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    "ownerId" character varying(14) NOT NULL
);


ALTER TABLE public."googlePlayPurchase" OWNER TO postgres;

--
-- Name: liveItems; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."liveItems" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    start timestamp without time zone NOT NULL,
    "end" timestamp without time zone,
    status character varying(14) NOT NULL,
    "episodeId" character varying(14) NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    "chatIRCURL" text
);


ALTER TABLE public."liveItems" OWNER TO postgres;

--
-- Name: mediaRefs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."mediaRefs" (
    id character varying(14) DEFAULT '1aLvCx9Y4'::character varying NOT NULL,
    "endTime" integer,
    "isPublic" boolean DEFAULT false NOT NULL,
    "pastHourTotalUniquePageviews" integer DEFAULT 0 NOT NULL,
    "pastDayTotalUniquePageviews" integer DEFAULT 0 NOT NULL,
    "pastWeekTotalUniquePageviews" integer DEFAULT 0 NOT NULL,
    "pastMonthTotalUniquePageviews" integer DEFAULT 0 NOT NULL,
    "pastYearTotalUniquePageviews" integer DEFAULT 0 NOT NULL,
    "pastAllTimeTotalUniquePageviews" integer DEFAULT 0 NOT NULL,
    "startTime" integer DEFAULT 0 NOT NULL,
    title character varying,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    "episodeId" character varying(14),
    "ownerId" character varying(14) NOT NULL,
    "imageUrl" character varying,
    "isOfficialChapter" boolean,
    "isOfficialSoundBite" boolean DEFAULT false NOT NULL,
    "linkUrl" character varying,
    int_id integer NOT NULL
);


ALTER TABLE public."mediaRefs" OWNER TO postgres;

--
-- Name: mediaRefs_int_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."mediaRefs_int_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."mediaRefs_int_id_seq" OWNER TO postgres;

--
-- Name: mediaRefs_int_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."mediaRefs_int_id_seq" OWNED BY public."mediaRefs".int_id;


--
-- Name: media_refs_authors_authors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.media_refs_authors_authors (
    "mediaRefsId" character varying(14) NOT NULL,
    "authorsId" character varying(14) NOT NULL
);


ALTER TABLE public.media_refs_authors_authors OWNER TO postgres;

--
-- Name: media_refs_categories_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.media_refs_categories_categories (
    "mediaRefsId" character varying(14) NOT NULL,
    "categoriesId" character varying(14) NOT NULL
);


ALTER TABLE public.media_refs_categories_categories OWNER TO postgres;

--
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    "podcastId" character varying(14) NOT NULL,
    "userId" character varying(14) NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- Name: paypalOrders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."paypalOrders" (
    "paymentID" character varying NOT NULL,
    state character varying,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    "ownerId" character varying(14) NOT NULL
);


ALTER TABLE public."paypalOrders" OWNER TO postgres;

--
-- Name: playlists; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.playlists (
    id character varying(14) DEFAULT 'unQFBUJIfL'::character varying NOT NULL,
    description character varying,
    "isPublic" boolean DEFAULT false NOT NULL,
    "itemCount" integer DEFAULT 0 NOT NULL,
    "itemsOrder" character varying[] NOT NULL,
    title character varying,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    "ownerId" character varying(14) NOT NULL,
    int_id integer NOT NULL
);


ALTER TABLE public.playlists OWNER TO postgres;

--
-- Name: playlists_episodes_episodes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.playlists_episodes_episodes (
    "playlistsId" character varying(14) NOT NULL,
    "episodesId" character varying(14) NOT NULL
);


ALTER TABLE public.playlists_episodes_episodes OWNER TO postgres;

--
-- Name: playlists_int_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.playlists_int_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.playlists_int_id_seq OWNER TO postgres;

--
-- Name: playlists_int_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.playlists_int_id_seq OWNED BY public.playlists.int_id;


--
-- Name: playlists_media_refs_media_refs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.playlists_media_refs_media_refs (
    "playlistsId" character varying(14) NOT NULL,
    "mediaRefsId" character varying(14) NOT NULL
);


ALTER TABLE public.playlists_media_refs_media_refs OWNER TO postgres;

--
-- Name: podcasts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.podcasts (
    id character varying(14) DEFAULT 'WBkZX19Ofd'::character varying NOT NULL,
    description character varying,
    "feedLastUpdated" timestamp without time zone,
    guid character varying,
    "imageUrl" character varying,
    "isExplicit" boolean DEFAULT false NOT NULL,
    "isPublic" boolean DEFAULT false NOT NULL,
    language character varying,
    "lastEpisodePubDate" timestamp without time zone,
    "lastEpisodeTitle" character varying,
    "linkUrl" character varying,
    "pastHourTotalUniquePageviews" integer DEFAULT 0 NOT NULL,
    "pastDayTotalUniquePageviews" integer DEFAULT 0 NOT NULL,
    "pastWeekTotalUniquePageviews" integer DEFAULT 0 NOT NULL,
    "pastMonthTotalUniquePageviews" integer DEFAULT 0 NOT NULL,
    "pastYearTotalUniquePageviews" integer DEFAULT 0 NOT NULL,
    "pastAllTimeTotalUniquePageviews" integer DEFAULT 0 NOT NULL,
    "shrunkImageUrl" character varying,
    "sortableTitle" character varying,
    title character varying,
    type character varying,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    "alwaysFullyParse" boolean DEFAULT false NOT NULL,
    "hideDynamicAdsWarning" boolean DEFAULT false NOT NULL,
    "authorityId" character varying,
    "feedLastParseFailed" boolean DEFAULT false NOT NULL,
    "podcastIndexId" character varying,
    funding text,
    value text,
    int_id integer NOT NULL,
    "shrunkImageLastUpdated" timestamp without time zone,
    "lastFoundInPodcastIndex" timestamp without time zone,
    "credentialsRequired" boolean DEFAULT false NOT NULL,
    "hasVideo" boolean DEFAULT false NOT NULL,
    medium public.podcasts_medium_enum DEFAULT 'podcast'::public.podcasts_medium_enum NOT NULL,
    "hasLiveItem" boolean DEFAULT false NOT NULL,
    subtitle character varying,
    "latestLiveItemStatus" public.podcasts_latest_live_item_status_enum DEFAULT 'none'::public.podcasts_latest_live_item_status_enum NOT NULL,
    "hasPodcastIndexValueTag" boolean DEFAULT false NOT NULL,
    persons jsonb,
    "embedApprovedMediaUrlPaths" text
);


ALTER TABLE public.podcasts OWNER TO postgres;

--
-- Name: podcasts_authors_authors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.podcasts_authors_authors (
    "podcastsId" character varying(14) NOT NULL,
    "authorsId" character varying(14) NOT NULL
);


ALTER TABLE public.podcasts_authors_authors OWNER TO postgres;

--
-- Name: podcasts_categories_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.podcasts_categories_categories (
    "podcastsId" character varying(14) NOT NULL,
    "categoriesId" character varying(14) NOT NULL
);


ALTER TABLE public.podcasts_categories_categories OWNER TO postgres;

--
-- Name: podcasts_int_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.podcasts_int_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.podcasts_int_id_seq OWNER TO postgres;

--
-- Name: podcasts_int_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.podcasts_int_id_seq OWNED BY public.podcasts.int_id;


--
-- Name: recentEpisodesByCategory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."recentEpisodesByCategory" (
    "categoryId" character varying NOT NULL,
    "episodeId" character varying NOT NULL,
    "pubDate" timestamp without time zone
);


ALTER TABLE public."recentEpisodesByCategory" OWNER TO postgres;

--
-- Name: recentEpisodesByPodcast; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."recentEpisodesByPodcast" (
    "podcastId" character varying NOT NULL,
    "episodeId" character varying NOT NULL,
    "pubDate" timestamp without time zone
);


ALTER TABLE public."recentEpisodesByPodcast" OWNER TO postgres;

--
-- Name: userHistoryItems; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."userHistoryItems" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "orderChangedDate" timestamp without time zone NOT NULL,
    "userPlaybackPosition" integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    "episodeId" character varying(14),
    "mediaRefId" character varying(14),
    "ownerId" character varying(14) NOT NULL,
    completed boolean DEFAULT false NOT NULL,
    "mediaFileDuration" integer DEFAULT 0 NOT NULL
);


ALTER TABLE public."userHistoryItems" OWNER TO postgres;

--
-- Name: userNowPlayingItems; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."userNowPlayingItems" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "userPlaybackPosition" integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    "episodeId" character varying(14),
    "mediaRefId" character varying(14),
    "ownerId" character varying(14) NOT NULL
);


ALTER TABLE public."userNowPlayingItems" OWNER TO postgres;

--
-- Name: userQueueItems; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."userQueueItems" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "queuePosition" integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    "episodeId" character varying(14),
    "mediaRefId" character varying(14),
    "ownerId" character varying(14) NOT NULL
);


ALTER TABLE public."userQueueItems" OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id character varying(14) DEFAULT 'W_XXeLRxSg'::character varying NOT NULL,
    email character varying NOT NULL,
    "emailVerificationToken" character varying,
    "emailVerificationTokenExpiration" timestamp without time zone,
    "emailVerified" boolean DEFAULT false NOT NULL,
    "freeTrialExpiration" timestamp without time zone,
    "isPublic" boolean DEFAULT false NOT NULL,
    "membershipExpiration" timestamp without time zone,
    name character varying,
    password character varying NOT NULL,
    "resetPasswordToken" character varying,
    "resetPasswordTokenExpiration" timestamp without time zone,
    roles character varying[] DEFAULT ARRAY[]::text[] NOT NULL,
    "subscribedPlaylistIds" character varying[] DEFAULT ARRAY[]::text[] NOT NULL,
    "subscribedPodcastIds" character varying[] DEFAULT ARRAY[]::text[] NOT NULL,
    "subscribedUserIds" character varying[] DEFAULT ARRAY[]::text[] NOT NULL,
    "historyItems" text NOT NULL,
    "queueItems" text NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    "addByRSSPodcastFeedUrls" character varying[] DEFAULT ARRAY[]::text[] NOT NULL,
    int_id integer NOT NULL,
    "userNowPlayingItemId" uuid,
    "subscribedPodcastListIds" character varying[] DEFAULT ARRAY[]::text[] NOT NULL,
    "isDevAdmin" boolean DEFAULT false NOT NULL,
    "isPodpingAdmin" boolean DEFAULT false NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_int_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_int_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_int_id_seq OWNER TO postgres;

--
-- Name: users_int_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_int_id_seq OWNED BY public.users.int_id;


--
-- Name: auth_group id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group ALTER COLUMN id SET DEFAULT nextval('public.auth_group_id_seq'::regclass);


--
-- Name: auth_group_permissions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group_permissions ALTER COLUMN id SET DEFAULT nextval('public.auth_group_permissions_id_seq'::regclass);


--
-- Name: auth_permission id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_permission ALTER COLUMN id SET DEFAULT nextval('public.auth_permission_id_seq'::regclass);


--
-- Name: auth_user id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user ALTER COLUMN id SET DEFAULT nextval('public.auth_user_id_seq'::regclass);


--
-- Name: auth_user_groups id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_groups ALTER COLUMN id SET DEFAULT nextval('public.auth_user_groups_id_seq'::regclass);


--
-- Name: auth_user_user_permissions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_user_permissions ALTER COLUMN id SET DEFAULT nextval('public.auth_user_user_permissions_id_seq'::regclass);


--
-- Name: authors int_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.authors ALTER COLUMN int_id SET DEFAULT nextval('public.authors_int_id_seq'::regclass);


--
-- Name: categories int_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories ALTER COLUMN int_id SET DEFAULT nextval('public.categories_int_id_seq'::regclass);


--
-- Name: django_admin_log id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_admin_log ALTER COLUMN id SET DEFAULT nextval('public.django_admin_log_id_seq'::regclass);


--
-- Name: django_content_type id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_content_type ALTER COLUMN id SET DEFAULT nextval('public.django_content_type_id_seq'::regclass);


--
-- Name: django_mfa_u2fkey id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_mfa_u2fkey ALTER COLUMN id SET DEFAULT nextval('public.django_mfa_u2fkey_id_seq'::regclass);


--
-- Name: django_mfa_userotp id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_mfa_userotp ALTER COLUMN id SET DEFAULT nextval('public.django_mfa_userotp_id_seq'::regclass);


--
-- Name: django_mfa_userrecoverycodes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_mfa_userrecoverycodes ALTER COLUMN id SET DEFAULT nextval('public.django_mfa_userrecoverycodes_id_seq'::regclass);


--
-- Name: django_migrations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_migrations ALTER COLUMN id SET DEFAULT nextval('public.django_migrations_id_seq'::regclass);


--
-- Name: episodes int_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episodes ALTER COLUMN int_id SET DEFAULT nextval('public.episodes_int_id_seq'::regclass);


--
-- Name: feedUrls int_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."feedUrls" ALTER COLUMN int_id SET DEFAULT nextval('public."feedUrls_int_id_seq"'::regclass);


--
-- Name: mediaRefs int_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."mediaRefs" ALTER COLUMN int_id SET DEFAULT nextval('public."mediaRefs_int_id_seq"'::regclass);


--
-- Name: playlists int_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlists ALTER COLUMN int_id SET DEFAULT nextval('public.playlists_int_id_seq'::regclass);


--
-- Name: podcasts int_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.podcasts ALTER COLUMN int_id SET DEFAULT nextval('public.podcasts_int_id_seq'::regclass);


--
-- Name: users int_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN int_id SET DEFAULT nextval('public.users_int_id_seq'::regclass);


--
-- Name: media_refs_authors_authors PK_13ec3e99f72c22113bcb03c07c7; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.media_refs_authors_authors
    ADD CONSTRAINT "PK_13ec3e99f72c22113bcb03c07c7" PRIMARY KEY ("mediaRefsId", "authorsId");


--
-- Name: recentEpisodesByCategory PK_14bb0ac7f5af05b338c8df8b057; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."recentEpisodesByCategory"
    ADD CONSTRAINT "PK_14bb0ac7f5af05b338c8df8b057" PRIMARY KEY ("categoryId", "episodeId");


--
-- Name: userQueueItems PK_1d8e6ae23c7d3b62412c010d281; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."userQueueItems"
    ADD CONSTRAINT "PK_1d8e6ae23c7d3b62412c010d281" PRIMARY KEY (id);


--
-- Name: appStorePurchase PK_1e318855e061f1e2347c8aa2509; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."appStorePurchase"
    ADD CONSTRAINT "PK_1e318855e061f1e2347c8aa2509" PRIMARY KEY ("transactionId");


--
-- Name: userHistoryItems PK_1e5be3f925a1a9b2b81f47b26a8; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."userHistoryItems"
    ADD CONSTRAINT "PK_1e5be3f925a1a9b2b81f47b26a8" PRIMARY KEY (id);


--
-- Name: recentEpisodesByPodcast PK_20f216a080ca2b8687edfdd32ff; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."recentEpisodesByPodcast"
    ADD CONSTRAINT "PK_20f216a080ca2b8687edfdd32ff" PRIMARY KEY ("podcastId", "episodeId");


--
-- Name: categories PK_24dbc6126a28ff948da33e97d3b; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT "PK_24dbc6126a28ff948da33e97d3b" PRIMARY KEY (id);


--
-- Name: paypalOrders PK_42034c78e07154787d29463201e; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."paypalOrders"
    ADD CONSTRAINT "PK_42034c78e07154787d29463201e" PRIMARY KEY ("paymentID");


--
-- Name: playlists_episodes_episodes PK_49b3461d449d03280132199d992; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlists_episodes_episodes
    ADD CONSTRAINT "PK_49b3461d449d03280132199d992" PRIMARY KEY ("playlistsId", "episodesId");


--
-- Name: mediaRefs PK_57b109c3ea01f45cbc6c0e6d9dc; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."mediaRefs"
    ADD CONSTRAINT "PK_57b109c3ea01f45cbc6c0e6d9dc" PRIMARY KEY (id);


--
-- Name: episodes PK_6a003fda8b0473fffc39cb831c7; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episodes
    ADD CONSTRAINT "PK_6a003fda8b0473fffc39cb831c7" PRIMARY KEY (id);


--
-- Name: podcasts PK_6df41936ccc877b29da54f11912; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.podcasts
    ADD CONSTRAINT "PK_6df41936ccc877b29da54f11912" PRIMARY KEY (id);


--
-- Name: bitpayInvoices PK_70744b6360f3ca78e7982cd9623; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."bitpayInvoices"
    ADD CONSTRAINT "PK_70744b6360f3ca78e7982cd9623" PRIMARY KEY (id);


--
-- Name: feedUrls PK_745ca62e733ed851b1523a5d4b7; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."feedUrls"
    ADD CONSTRAINT "PK_745ca62e733ed851b1523a5d4b7" PRIMARY KEY (id);


--
-- Name: accountClaimToken PK_826e5218856a31c9a6e4cce978d; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."accountClaimToken"
    ADD CONSTRAINT "PK_826e5218856a31c9a6e4cce978d" PRIMARY KEY (id);


--
-- Name: userNowPlayingItems PK_88121e9a38cdc5823517e43b773; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."userNowPlayingItems"
    ADD CONSTRAINT "PK_88121e9a38cdc5823517e43b773" PRIMARY KEY (id);


--
-- Name: users PK_a3ffb1c0c8416b9fc6f907b7433; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "PK_a3ffb1c0c8416b9fc6f907b7433" PRIMARY KEY (id);


--
-- Name: playlists PK_a4597f4189a75d20507f3f7ef0d; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlists
    ADD CONSTRAINT "PK_a4597f4189a75d20507f3f7ef0d" PRIMARY KEY (id);


--
-- Name: podcasts_authors_authors PK_ac8359699e84adf859737e036a7; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.podcasts_authors_authors
    ADD CONSTRAINT "PK_ac8359699e84adf859737e036a7" PRIMARY KEY ("podcastsId", "authorsId");


--
-- Name: podcasts_categories_categories PK_bbae8cd165bde36683f61857d65; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.podcasts_categories_categories
    ADD CONSTRAINT "PK_bbae8cd165bde36683f61857d65" PRIMARY KEY ("podcastsId", "categoriesId");


--
-- Name: googlePlayPurchase PK_cda3543f03a46d6faf14eede9c9; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."googlePlayPurchase"
    ADD CONSTRAINT "PK_cda3543f03a46d6faf14eede9c9" PRIMARY KEY ("transactionId");


--
-- Name: authors PK_d2ed02fabd9b52847ccb85e6b88; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.authors
    ADD CONSTRAINT "PK_d2ed02fabd9b52847ccb85e6b88" PRIMARY KEY (id);


--
-- Name: media_refs_categories_categories PK_de67c8b106abfb076a0fe064102; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.media_refs_categories_categories
    ADD CONSTRAINT "PK_de67c8b106abfb076a0fe064102" PRIMARY KEY ("mediaRefsId", "categoriesId");


--
-- Name: episodes_authors_authors PK_e7eeb23901ed155b98adff391e8; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episodes_authors_authors
    ADD CONSTRAINT "PK_e7eeb23901ed155b98adff391e8" PRIMARY KEY ("episodesId", "authorsId");


--
-- Name: episodes_categories_categories PK_efc81557aabf1fbc5b24871f347; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episodes_categories_categories
    ADD CONSTRAINT "PK_efc81557aabf1fbc5b24871f347" PRIMARY KEY ("episodesId", "categoriesId");


--
-- Name: playlists_media_refs_media_refs PK_f5df63949efe0c9c6c2952778fe; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlists_media_refs_media_refs
    ADD CONSTRAINT "PK_f5df63949efe0c9c6c2952778fe" PRIMARY KEY ("playlistsId", "mediaRefsId");


--
-- Name: liveItems PK_liveItems; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."liveItems"
    ADD CONSTRAINT "PK_liveItems" PRIMARY KEY (id);


--
-- Name: userNowPlayingItems REL_5b75c715cf270b9fcd22e84a2d; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."userNowPlayingItems"
    ADD CONSTRAINT "REL_5b75c715cf270b9fcd22e84a2d" UNIQUE ("ownerId");


--
-- Name: bitpayInvoices UQ_196fcb310be5f27e20daca29c18; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."bitpayInvoices"
    ADD CONSTRAINT "UQ_196fcb310be5f27e20daca29c18" UNIQUE (token);


--
-- Name: podcasts UQ_256bb9730eb32a6736c1ce1bdda; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.podcasts
    ADD CONSTRAINT "UQ_256bb9730eb32a6736c1ce1bdda" UNIQUE ("authorityId");


--
-- Name: users UQ_4e8c8c78bc87861c7fb6b44bd3f; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "UQ_4e8c8c78bc87861c7fb6b44bd3f" UNIQUE ("resetPasswordToken");


--
-- Name: googlePlayPurchase UQ_55bf0e14679e47a46958456924f; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."googlePlayPurchase"
    ADD CONSTRAINT "UQ_55bf0e14679e47a46958456924f" UNIQUE ("purchaseToken");


--
-- Name: users UQ_7ad75a333a7bcf6a2b5d3517ca8; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "UQ_7ad75a333a7bcf6a2b5d3517ca8" UNIQUE ("emailVerificationToken");


--
-- Name: users UQ_94bd438add251d5ba3e72d023c3; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "UQ_94bd438add251d5ba3e72d023c3" UNIQUE ("userNowPlayingItemId");


--
-- Name: users UQ_97672ac88f789774dd47f7c8be3; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "UQ_97672ac88f789774dd47f7c8be3" UNIQUE (email);


--
-- Name: categories UQ_aa79448dc3e959720ab4c13651d; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT "UQ_aa79448dc3e959720ab4c13651d" UNIQUE (title);


--
-- Name: podcasts UQ_c5c5dd158252f99509fcded0d6c; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.podcasts
    ADD CONSTRAINT "UQ_c5c5dd158252f99509fcded0d6c" UNIQUE ("podcastIndexId");


--
-- Name: bitpayInvoices UQ_cc02450054d1eb4e878a02798e7; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."bitpayInvoices"
    ADD CONSTRAINT "UQ_cc02450054d1eb4e878a02798e7" UNIQUE ("orderId");


--
-- Name: feedUrls UQ_dbf6f5af7383c74830c961f98f1; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."feedUrls"
    ADD CONSTRAINT "UQ_dbf6f5af7383c74830c961f98f1" UNIQUE (url);


--
-- Name: categories UQ_dcece68ce217472405c77338fae; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT "UQ_dcece68ce217472405c77338fae" UNIQUE ("fullPath");


--
-- Name: authors UQ_f068a15d416578e89d41189ca25; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.authors
    ADD CONSTRAINT "UQ_f068a15d416578e89d41189ca25" UNIQUE (slug);


--
-- Name: auth_group auth_group_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_name_key UNIQUE (name);


--
-- Name: auth_group_permissions auth_group_permissions_group_id_permission_id_0cd325b0_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_permission_id_0cd325b0_uniq UNIQUE (group_id, permission_id);


--
-- Name: auth_group_permissions auth_group_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_pkey PRIMARY KEY (id);


--
-- Name: auth_group auth_group_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_pkey PRIMARY KEY (id);


--
-- Name: auth_permission auth_permission_content_type_id_codename_01ab375a_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_codename_01ab375a_uniq UNIQUE (content_type_id, codename);


--
-- Name: auth_permission auth_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_pkey PRIMARY KEY (id);


--
-- Name: auth_user_groups auth_user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_pkey PRIMARY KEY (id);


--
-- Name: auth_user_groups auth_user_groups_user_id_group_id_94350c0c_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_user_id_group_id_94350c0c_uniq UNIQUE (user_id, group_id);


--
-- Name: auth_user auth_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user
    ADD CONSTRAINT auth_user_pkey PRIMARY KEY (id);


--
-- Name: auth_user_user_permissions auth_user_user_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_pkey PRIMARY KEY (id);


--
-- Name: auth_user_user_permissions auth_user_user_permissions_user_id_permission_id_14a6b632_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_user_id_permission_id_14a6b632_uniq UNIQUE (user_id, permission_id);


--
-- Name: auth_user auth_user_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user
    ADD CONSTRAINT auth_user_username_key UNIQUE (username);


--
-- Name: django_admin_log django_admin_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_pkey PRIMARY KEY (id);


--
-- Name: django_content_type django_content_type_app_label_model_76bd3d3b_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_app_label_model_76bd3d3b_uniq UNIQUE (app_label, model);


--
-- Name: django_content_type django_content_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_pkey PRIMARY KEY (id);


--
-- Name: django_mfa_u2fkey django_mfa_u2fkey_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_mfa_u2fkey
    ADD CONSTRAINT django_mfa_u2fkey_pkey PRIMARY KEY (id);


--
-- Name: django_mfa_u2fkey django_mfa_u2fkey_public_key_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_mfa_u2fkey
    ADD CONSTRAINT django_mfa_u2fkey_public_key_key UNIQUE (public_key);


--
-- Name: django_mfa_userotp django_mfa_userotp_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_mfa_userotp
    ADD CONSTRAINT django_mfa_userotp_pkey PRIMARY KEY (id);


--
-- Name: django_mfa_userotp django_mfa_userotp_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_mfa_userotp
    ADD CONSTRAINT django_mfa_userotp_user_id_key UNIQUE (user_id);


--
-- Name: django_mfa_userrecoverycodes django_mfa_userrecoverycodes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_mfa_userrecoverycodes
    ADD CONSTRAINT django_mfa_userrecoverycodes_pkey PRIMARY KEY (id);


--
-- Name: django_migrations django_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_migrations
    ADD CONSTRAINT django_migrations_pkey PRIMARY KEY (id);


--
-- Name: django_session django_session_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_session
    ADD CONSTRAINT django_session_pkey PRIMARY KEY (session_key);


--
-- Name: episodes episodes_int_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episodes
    ADD CONSTRAINT episodes_int_id_key UNIQUE (int_id);


--
-- Name: fcmDevices fcmDevices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."fcmDevices"
    ADD CONSTRAINT "fcmDevices_pkey" PRIMARY KEY ("fcmToken");


--
-- Name: feedUrls feedUrl_index_podcastId_isAuthority; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."feedUrls"
    ADD CONSTRAINT "feedUrl_index_podcastId_isAuthority" UNIQUE ("podcastId", "isAuthority");


--
-- Name: userHistoryItems index_episode_owner; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."userHistoryItems"
    ADD CONSTRAINT index_episode_owner UNIQUE ("episodeId", "ownerId");


--
-- Name: feedUrls index_feedUrlId_isAuthority; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."feedUrls"
    ADD CONSTRAINT "index_feedUrlId_isAuthority" UNIQUE (id, "isAuthority");


--
-- Name: userHistoryItems index_mediaRef_owner; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."userHistoryItems"
    ADD CONSTRAINT "index_mediaRef_owner" UNIQUE ("mediaRefId", "ownerId");


--
-- Name: mediaRefs mediaRef_index_episode_isOfficialChapter_startTime; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."mediaRefs"
    ADD CONSTRAINT "mediaRef_index_episode_isOfficialChapter_startTime" UNIQUE ("episodeId", "isOfficialChapter", "startTime");


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY ("podcastId", "userId");


--
-- Name: IDX_02685aea54efa70d3010f87591; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_02685aea54efa70d3010f87591" ON public.playlists_episodes_episodes USING btree ("episodesId");


--
-- Name: IDX_0969e6fb7a3e44c9378ad70af2; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_0969e6fb7a3e44c9378ad70af2" ON public.podcasts USING btree ("sortableTitle");


--
-- Name: IDX_09a8c725fd0ba645328586f72e; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_09a8c725fd0ba645328586f72e" ON public."mediaRefs" USING btree ("pastHourTotalUniquePageviews");


--
-- Name: IDX_09ae4505e3b4b2ddb27486187a; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_09ae4505e3b4b2ddb27486187a" ON public.podcasts USING btree ("feedLastUpdated");


--
-- Name: IDX_0fe77506692eddad6e575a8f2c; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_0fe77506692eddad6e575a8f2c" ON public."mediaRefs" USING btree ("pastMonthTotalUniquePageviews");


--
-- Name: IDX_11683ae7e6c4ddea9fbc7c16c9; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_11683ae7e6c4ddea9fbc7c16c9" ON public."mediaRefs" USING btree ("startTime");


--
-- Name: IDX_11b01d1ed43460c820c32d628d; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_11b01d1ed43460c820c32d628d" ON public.playlists USING btree ("isPublic");


--
-- Name: IDX_13e66683931cb80f2695cd5d41; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_13e66683931cb80f2695cd5d41" ON public.episodes USING btree (guid);


--
-- Name: IDX_14bb0ac7f5af05b338c8df8b05; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_14bb0ac7f5af05b338c8df8b05" ON public."recentEpisodesByCategory" USING btree ("categoryId", "episodeId");


--
-- Name: IDX_17ffc2169d96b1236156c9d1af; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_17ffc2169d96b1236156c9d1af" ON public."mediaRefs" USING btree ("isPublic");


--
-- Name: IDX_18eeb5e01ccce3b6d2810444f2; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_18eeb5e01ccce3b6d2810444f2" ON public."mediaRefs" USING btree ("episodeId");


--
-- Name: IDX_19ff4092d18bbfc1965aa26b29; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_19ff4092d18bbfc1965aa26b29" ON public.episodes USING btree ("podcastId");


--
-- Name: IDX_1a6fc2c8e0b2401e926fdc9ea8; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_1a6fc2c8e0b2401e926fdc9ea8" ON public.episodes USING btree ("mediaType", "pastDayTotalUniquePageviews");


--
-- Name: IDX_20f216a080ca2b8687edfdd32f; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_20f216a080ca2b8687edfdd32f" ON public."recentEpisodesByPodcast" USING btree ("podcastId", "episodeId");


--
-- Name: IDX_2176f5be7a06ca1209c9032e23; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_2176f5be7a06ca1209c9032e23" ON public.podcasts_authors_authors USING btree ("authorsId");


--
-- Name: IDX_256bb9730eb32a6736c1ce1bdd; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_256bb9730eb32a6736c1ce1bdd" ON public.podcasts USING btree ("authorityId");


--
-- Name: IDX_2cf53215e8e84587ec8e8a7cdd; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_2cf53215e8e84587ec8e8a7cdd" ON public.episodes USING btree ("isPublic", "pubDate");


--
-- Name: IDX_2dd75798bb599b9ced1c491c02; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_2dd75798bb599b9ced1c491c02" ON public.podcasts USING btree ("hasVideo", "pastHourTotalUniquePageviews");


--
-- Name: IDX_30403fff476188bfb18fd38f10; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_30403fff476188bfb18fd38f10" ON public.podcasts USING btree ("shrunkImageLastUpdated");


--
-- Name: IDX_399bc5a8d308e7c03d7d069d11; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_399bc5a8d308e7c03d7d069d11" ON public.episodes USING btree ("mediaType");


--
-- Name: IDX_420d9f679d41281f282f5bc7d0; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_420d9f679d41281f282f5bc7d0" ON public.categories USING btree (slug);


--
-- Name: IDX_4a7b9c20b0f1e5a7e3a4db1a1d; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_4a7b9c20b0f1e5a7e3a4db1a1d" ON public.media_refs_categories_categories USING btree ("mediaRefsId");


--
-- Name: IDX_4bafa72e53c0f10cf22f765c9b; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_4bafa72e53c0f10cf22f765c9b" ON public.podcasts USING btree ("hasVideo", "pastAllTimeTotalUniquePageviews");


--
-- Name: IDX_512bbce3fc715a1248da50c3b1; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_512bbce3fc715a1248da50c3b1" ON public.playlists_episodes_episodes USING btree ("playlistsId");


--
-- Name: IDX_51b8b26ac168fbe7d6f5653e6c; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_51b8b26ac168fbe7d6f5653e6c" ON public.users USING btree (name);


--
-- Name: IDX_537ed19be00c0a556c3b6daf91; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_537ed19be00c0a556c3b6daf91" ON public.episodes_categories_categories USING btree ("episodesId");


--
-- Name: IDX_541f35addc2a77f2f28168953d; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_541f35addc2a77f2f28168953d" ON public.podcasts USING btree ("hasVideo", "pastYearTotalUniquePageviews");


--
-- Name: IDX_54d1c28ab0771a49dbe87b0dcc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_54d1c28ab0771a49dbe87b0dcc" ON public.episodes USING btree ("mediaType", "pastWeekTotalUniquePageviews");


--
-- Name: IDX_571bbf908b797f80b595a9690b; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_571bbf908b797f80b595a9690b" ON public."mediaRefs" USING btree ("pastDayTotalUniquePageviews");


--
-- Name: IDX_572f275df88fcfb6286c001cce; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_572f275df88fcfb6286c001cce" ON public."mediaRefs" USING btree (title);


--
-- Name: IDX_5799a9d6ce7ce4b999671beff7; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_5799a9d6ce7ce4b999671beff7" ON public.podcasts USING btree ("lastEpisodePubDate");


--
-- Name: IDX_5af18e38f12003a8e9bd25adfa; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_5af18e38f12003a8e9bd25adfa" ON public.episodes USING btree ("pastHourTotalUniquePageviews");


--
-- Name: IDX_615eeb67c60e861faab5d4f491; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_615eeb67c60e861faab5d4f491" ON public.podcasts USING btree ("isPublic");


--
-- Name: IDX_62a37551f90877865acd36bc73; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_62a37551f90877865acd36bc73" ON public.episodes USING btree ("pastAllTimeTotalUniquePageviews");


--
-- Name: IDX_6a47478e3666025fe25cc64276; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_6a47478e3666025fe25cc64276" ON public.podcasts USING btree ("hasVideo", "pastDayTotalUniquePageviews");


--
-- Name: IDX_6c64b3df09e6774438aeca7e0b; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_6c64b3df09e6774438aeca7e0b" ON public.authors USING btree (name);


--
-- Name: IDX_6d6e0875555cd123471bc8ced4; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_6d6e0875555cd123471bc8ced4" ON public.podcasts USING btree ("hasVideo", "pastMonthTotalUniquePageviews");


--
-- Name: IDX_6ecc7fa0b9240caf664bba88d7; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_6ecc7fa0b9240caf664bba88d7" ON public.media_refs_categories_categories USING btree ("categoriesId");


--
-- Name: IDX_767302e1963b286fac519d5fa0; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_767302e1963b286fac519d5fa0" ON public.episodes_categories_categories USING btree ("categoriesId");


--
-- Name: IDX_7aaa96d87796f0de409665a7fd; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_7aaa96d87796f0de409665a7fd" ON public.episodes_authors_authors USING btree ("episodesId");


--
-- Name: IDX_7ab36ec4759b09ba63842c3c39; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_7ab36ec4759b09ba63842c3c39" ON public.podcasts USING btree ("pastMonthTotalUniquePageviews");


--
-- Name: IDX_80c725139ef1eb54e57077e96a; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_80c725139ef1eb54e57077e96a" ON public."recentEpisodesByCategory" USING btree ("pubDate");


--
-- Name: IDX_8708e4136a01077cb833e5cc0a; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_8708e4136a01077cb833e5cc0a" ON public."recentEpisodesByPodcast" USING btree ("pubDate");


--
-- Name: IDX_87922d33aa3cd4ac47558e638c; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_87922d33aa3cd4ac47558e638c" ON public.media_refs_authors_authors USING btree ("authorsId");


--
-- Name: IDX_8809e744be7ee07ebcb77d0e40; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_8809e744be7ee07ebcb77d0e40" ON public.episodes USING btree ("mediaType", "pastAllTimeTotalUniquePageviews");


--
-- Name: IDX_905f8e115445319050b9e75f0d; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_905f8e115445319050b9e75f0d" ON public."mediaRefs" USING btree ("pastYearTotalUniquePageviews");


--
-- Name: IDX_92cd818c2518ed4507a31f3932; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_92cd818c2518ed4507a31f3932" ON public.episodes USING btree ("pastMonthTotalUniquePageviews");


--
-- Name: IDX_941280324aa87b9b98b5543b5b; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_941280324aa87b9b98b5543b5b" ON public.playlists USING btree (title);


--
-- Name: IDX_97672ac88f789774dd47f7c8be; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_97672ac88f789774dd47f7c8be" ON public.users USING btree (email);


--
-- Name: IDX_9a2ddcfc55440e921f58e06e4a; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_9a2ddcfc55440e921f58e06e4a" ON public.episodes_authors_authors USING btree ("authorsId");


--
-- Name: IDX_9d3df9a4193ffcd5dce7932057; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_9d3df9a4193ffcd5dce7932057" ON public.podcasts USING btree ("pastWeekTotalUniquePageviews");


--
-- Name: IDX_a62d8df41ff49a59fd04033a58; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_a62d8df41ff49a59fd04033a58" ON public.podcasts USING btree ("pastDayTotalUniquePageviews");


--
-- Name: IDX_a65598c2450c4f601ecb341994; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_a65598c2450c4f601ecb341994" ON public.podcasts USING btree (title);


--
-- Name: IDX_aa79448dc3e959720ab4c13651; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_aa79448dc3e959720ab4c13651" ON public.categories USING btree (title);


--
-- Name: IDX_acd3fd6c4dff47ee1cd00ac582; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_acd3fd6c4dff47ee1cd00ac582" ON public.episodes USING btree (title);


--
-- Name: IDX_acefc4d091700acb0d7faf25b8; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_acefc4d091700acb0d7faf25b8" ON public.podcasts USING btree ("hasVideo", "pastWeekTotalUniquePageviews");


--
-- Name: IDX_b2623d89f86f38debe0c414578; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_b2623d89f86f38debe0c414578" ON public.podcasts USING btree ("pastHourTotalUniquePageviews");


--
-- Name: IDX_b4e928000238b50d848c0f3684; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_b4e928000238b50d848c0f3684" ON public.podcasts_categories_categories USING btree ("podcastsId");


--
-- Name: IDX_b651ccc2eec2cb1936244ea742; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_b651ccc2eec2cb1936244ea742" ON public."userQueueItems" USING btree ("ownerId");


--
-- Name: IDX_bd2336c4578b5fe56594c7b9d2; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_bd2336c4578b5fe56594c7b9d2" ON public.podcasts USING btree ("pastAllTimeTotalUniquePageviews");


--
-- Name: IDX_bf209f7f5e4fb4e83e73b5f2a4; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_bf209f7f5e4fb4e83e73b5f2a4" ON public.episodes USING btree ("pastYearTotalUniquePageviews");


--
-- Name: IDX_c1bc0ffc58bc3174371de14a2a; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_c1bc0ffc58bc3174371de14a2a" ON public.episodes USING btree ("mediaType", "pastYearTotalUniquePageviews");


--
-- Name: IDX_c5c5dd158252f99509fcded0d6; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_c5c5dd158252f99509fcded0d6" ON public.podcasts USING btree ("podcastIndexId");


--
-- Name: IDX_cb6e0c6ebc9d77ea096c299c4f; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cb6e0c6ebc9d77ea096c299c4f" ON public.episodes USING btree ("mediaType", "pastHourTotalUniquePageviews");


--
-- Name: IDX_cc02450054d1eb4e878a02798e; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cc02450054d1eb4e878a02798e" ON public."bitpayInvoices" USING btree ("orderId");


--
-- Name: IDX_cfa3de60daca1fdd5a10e68faa; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cfa3de60daca1fdd5a10e68faa" ON public.podcasts_categories_categories USING btree ("categoriesId");


--
-- Name: IDX_d7710685515eb9325deaba0fb6; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_d7710685515eb9325deaba0fb6" ON public.episodes USING btree ("mediaType", "pastMonthTotalUniquePageviews");


--
-- Name: IDX_da6fc438d37c65927437b3107f; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_da6fc438d37c65927437b3107f" ON public.episodes USING btree ("mediaUrl");


--
-- Name: IDX_dbf6f5af7383c74830c961f98f; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_dbf6f5af7383c74830c961f98f" ON public."feedUrls" USING btree (url);


--
-- Name: IDX_dc5be6361ad85f97f00292b066; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_dc5be6361ad85f97f00292b066" ON public."mediaRefs" USING btree ("pastWeekTotalUniquePageviews");


--
-- Name: IDX_dcece68ce217472405c77338fa; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_dcece68ce217472405c77338fa" ON public.categories USING btree ("fullPath");


--
-- Name: IDX_dfcf4b77555659379068cce3c7; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_dfcf4b77555659379068cce3c7" ON public."mediaRefs" USING btree ("pastAllTimeTotalUniquePageviews");


--
-- Name: IDX_e43c5eb439402e4f0622673661; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_e43c5eb439402e4f0622673661" ON public."userHistoryItems" USING btree ("ownerId");


--
-- Name: IDX_e4c61e9c929b3bafc7c7a36acf; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_e4c61e9c929b3bafc7c7a36acf" ON public.podcasts USING btree ("pastYearTotalUniquePageviews");


--
-- Name: IDX_e82794b81decc63a21c888e354; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_e82794b81decc63a21c888e354" ON public.users USING btree ("isPublic");


--
-- Name: IDX_ee4ab0af0bf6e1be5506d9989a; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_ee4ab0af0bf6e1be5506d9989a" ON public.episodes USING btree ("pastDayTotalUniquePageviews");


--
-- Name: IDX_f068a15d416578e89d41189ca2; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_f068a15d416578e89d41189ca2" ON public.authors USING btree (slug);


--
-- Name: IDX_f380a166d117b8c864caf5d832; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_f380a166d117b8c864caf5d832" ON public.media_refs_authors_authors USING btree ("mediaRefsId");


--
-- Name: IDX_f4f7f745bb43687e941e6cdd61; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_f4f7f745bb43687e941e6cdd61" ON public.episodes USING btree ("pastWeekTotalUniquePageviews");


--
-- Name: IDX_f85c01764ccf3287ddaeb44fc6; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_f85c01764ccf3287ddaeb44fc6" ON public.playlists_media_refs_media_refs USING btree ("mediaRefsId");


--
-- Name: IDX_fc0a928532ac8066e06c3dd125; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_fc0a928532ac8066e06c3dd125" ON public.playlists_media_refs_media_refs USING btree ("playlistsId");


--
-- Name: IDX_fcmDevices_userId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_fcmDevices_userId" ON public."fcmDevices" USING btree ("userId");


--
-- Name: IDX_ff3fe42ceba07c5d88125a0d78; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_ff3fe42ceba07c5d88125a0d78" ON public.podcasts_authors_authors USING btree ("podcastsId");


--
-- Name: auth_group_name_a6ea08ec_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_group_name_a6ea08ec_like ON public.auth_group USING btree (name varchar_pattern_ops);


--
-- Name: auth_group_permissions_group_id_b120cbf9; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_group_permissions_group_id_b120cbf9 ON public.auth_group_permissions USING btree (group_id);


--
-- Name: auth_group_permissions_permission_id_84c5c92e; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_group_permissions_permission_id_84c5c92e ON public.auth_group_permissions USING btree (permission_id);


--
-- Name: auth_permission_content_type_id_2f476e4b; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_permission_content_type_id_2f476e4b ON public.auth_permission USING btree (content_type_id);


--
-- Name: auth_user_groups_group_id_97559544; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_user_groups_group_id_97559544 ON public.auth_user_groups USING btree (group_id);


--
-- Name: auth_user_groups_user_id_6a12ed8b; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_user_groups_user_id_6a12ed8b ON public.auth_user_groups USING btree (user_id);


--
-- Name: auth_user_user_permissions_permission_id_1fbb5f2c; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_user_user_permissions_permission_id_1fbb5f2c ON public.auth_user_user_permissions USING btree (permission_id);


--
-- Name: auth_user_user_permissions_user_id_a95ead1b; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_user_user_permissions_user_id_a95ead1b ON public.auth_user_user_permissions USING btree (user_id);


--
-- Name: auth_user_username_6821ab7c_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_user_username_6821ab7c_like ON public.auth_user USING btree (username varchar_pattern_ops);


--
-- Name: authors_int_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX authors_int_id_index ON public.authors USING btree (int_id);


--
-- Name: categories_int_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX categories_int_id_index ON public.categories USING btree (int_id);


--
-- Name: django_admin_log_content_type_id_c4bce8eb; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_admin_log_content_type_id_c4bce8eb ON public.django_admin_log USING btree (content_type_id);


--
-- Name: django_admin_log_user_id_c564eba6; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_admin_log_user_id_c564eba6 ON public.django_admin_log USING btree (user_id);


--
-- Name: django_mfa_u2fkey_public_key_3d303fe9_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_mfa_u2fkey_public_key_3d303fe9_like ON public.django_mfa_u2fkey USING btree (public_key text_pattern_ops);


--
-- Name: django_mfa_u2fkey_user_id_2d00d3c1; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_mfa_u2fkey_user_id_2d00d3c1 ON public.django_mfa_u2fkey USING btree (user_id);


--
-- Name: django_mfa_userrecoverycodes_user_id_2cb8601a; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_mfa_userrecoverycodes_user_id_2cb8601a ON public.django_mfa_userrecoverycodes USING btree (user_id);


--
-- Name: django_session_expire_date_a5c62663; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_session_expire_date_a5c62663 ON public.django_session USING btree (expire_date);


--
-- Name: django_session_session_key_c0390e0f_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_session_session_key_c0390e0f_like ON public.django_session USING btree (session_key varchar_pattern_ops);


--
-- Name: feedUrls_int_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "feedUrls_int_id_index" ON public."feedUrls" USING btree (int_id);


--
-- Name: idx_episodes_ispublic; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_episodes_ispublic ON public.episodes USING btree ("isPublic");


--
-- Name: mediaRefs_int_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "mediaRefs_int_id_index" ON public."mediaRefs" USING btree (int_id);


--
-- Name: playlists_int_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX playlists_int_id_index ON public.playlists USING btree (int_id);


--
-- Name: podcasts_int_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX podcasts_int_id_index ON public.podcasts USING btree (int_id);


--
-- Name: users_int_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_int_id_index ON public.users USING btree (int_id);


--
-- Name: playlists_episodes_episodes FK_02685aea54efa70d3010f875910; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlists_episodes_episodes
    ADD CONSTRAINT "FK_02685aea54efa70d3010f875910" FOREIGN KEY ("episodesId") REFERENCES public.episodes(id) ON DELETE CASCADE;


--
-- Name: mediaRefs FK_18eeb5e01ccce3b6d2810444f28; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."mediaRefs"
    ADD CONSTRAINT "FK_18eeb5e01ccce3b6d2810444f28" FOREIGN KEY ("episodeId") REFERENCES public.episodes(id) ON DELETE CASCADE;


--
-- Name: episodes FK_19ff4092d18bbfc1965aa26b290; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episodes
    ADD CONSTRAINT "FK_19ff4092d18bbfc1965aa26b290" FOREIGN KEY ("podcastId") REFERENCES public.podcasts(id) ON DELETE CASCADE;


--
-- Name: appStorePurchase FK_1dd6373b3338e58038b1d0b65cf; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."appStorePurchase"
    ADD CONSTRAINT "FK_1dd6373b3338e58038b1d0b65cf" FOREIGN KEY ("ownerId") REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: podcasts_authors_authors FK_2176f5be7a06ca1209c9032e23d; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.podcasts_authors_authors
    ADD CONSTRAINT "FK_2176f5be7a06ca1209c9032e23d" FOREIGN KEY ("authorsId") REFERENCES public.authors(id) ON DELETE CASCADE;


--
-- Name: userQueueItems FK_2367e28002d5b0e577e5084b967; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."userQueueItems"
    ADD CONSTRAINT "FK_2367e28002d5b0e577e5084b967" FOREIGN KEY ("episodeId") REFERENCES public.episodes(id) ON DELETE CASCADE;


--
-- Name: googlePlayPurchase FK_26de9b598078b3441a14f28aa81; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."googlePlayPurchase"
    ADD CONSTRAINT "FK_26de9b598078b3441a14f28aa81" FOREIGN KEY ("ownerId") REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: userNowPlayingItems FK_47b0e8ccc83c3a9f97ee4b2e343; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."userNowPlayingItems"
    ADD CONSTRAINT "FK_47b0e8ccc83c3a9f97ee4b2e343" FOREIGN KEY ("episodeId") REFERENCES public.episodes(id) ON DELETE CASCADE;


--
-- Name: media_refs_categories_categories FK_4a7b9c20b0f1e5a7e3a4db1a1d8; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.media_refs_categories_categories
    ADD CONSTRAINT "FK_4a7b9c20b0f1e5a7e3a4db1a1d8" FOREIGN KEY ("mediaRefsId") REFERENCES public."mediaRefs"(id) ON DELETE CASCADE;


--
-- Name: playlists_episodes_episodes FK_512bbce3fc715a1248da50c3b1b; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlists_episodes_episodes
    ADD CONSTRAINT "FK_512bbce3fc715a1248da50c3b1b" FOREIGN KEY ("playlistsId") REFERENCES public.playlists(id) ON DELETE CASCADE;


--
-- Name: episodes_categories_categories FK_537ed19be00c0a556c3b6daf91f; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episodes_categories_categories
    ADD CONSTRAINT "FK_537ed19be00c0a556c3b6daf91f" FOREIGN KEY ("episodesId") REFERENCES public.episodes(id) ON DELETE CASCADE;


--
-- Name: userNowPlayingItems FK_5b75c715cf270b9fcd22e84a2dd; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."userNowPlayingItems"
    ADD CONSTRAINT "FK_5b75c715cf270b9fcd22e84a2dd" FOREIGN KEY ("ownerId") REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: userQueueItems FK_5d3167b5c0df34e3a550fd8d6e8; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."userQueueItems"
    ADD CONSTRAINT "FK_5d3167b5c0df34e3a550fd8d6e8" FOREIGN KEY ("mediaRefId") REFERENCES public."mediaRefs"(id);


--
-- Name: paypalOrders FK_6926d78c096069bbb0bc7463588; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."paypalOrders"
    ADD CONSTRAINT "FK_6926d78c096069bbb0bc7463588" FOREIGN KEY ("ownerId") REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: media_refs_categories_categories FK_6ecc7fa0b9240caf664bba88d7f; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.media_refs_categories_categories
    ADD CONSTRAINT "FK_6ecc7fa0b9240caf664bba88d7f" FOREIGN KEY ("categoriesId") REFERENCES public.categories(id) ON DELETE CASCADE;


--
-- Name: episodes_categories_categories FK_767302e1963b286fac519d5fa05; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episodes_categories_categories
    ADD CONSTRAINT "FK_767302e1963b286fac519d5fa05" FOREIGN KEY ("categoriesId") REFERENCES public.categories(id) ON DELETE CASCADE;


--
-- Name: episodes_authors_authors FK_7aaa96d87796f0de409665a7fdb; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episodes_authors_authors
    ADD CONSTRAINT "FK_7aaa96d87796f0de409665a7fdb" FOREIGN KEY ("episodesId") REFERENCES public.episodes(id) ON DELETE CASCADE;


--
-- Name: media_refs_authors_authors FK_87922d33aa3cd4ac47558e638c6; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.media_refs_authors_authors
    ADD CONSTRAINT "FK_87922d33aa3cd4ac47558e638c6" FOREIGN KEY ("authorsId") REFERENCES public.authors(id) ON DELETE CASCADE;


--
-- Name: mediaRefs FK_938554feb8b5e73f6caa18896dc; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."mediaRefs"
    ADD CONSTRAINT "FK_938554feb8b5e73f6caa18896dc" FOREIGN KEY ("ownerId") REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: users FK_94bd438add251d5ba3e72d023c3; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "FK_94bd438add251d5ba3e72d023c3" FOREIGN KEY ("userNowPlayingItemId") REFERENCES public."userNowPlayingItems"(id);


--
-- Name: episodes_authors_authors FK_9a2ddcfc55440e921f58e06e4a6; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episodes_authors_authors
    ADD CONSTRAINT "FK_9a2ddcfc55440e921f58e06e4a6" FOREIGN KEY ("authorsId") REFERENCES public.authors(id) ON DELETE CASCADE;


--
-- Name: playlists FK_aa5d498a2f045be2fb71ef98d45; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlists
    ADD CONSTRAINT "FK_aa5d498a2f045be2fb71ef98d45" FOREIGN KEY ("ownerId") REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: userHistoryItems FK_acfcaa8bcf9c198372a9b90207b; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."userHistoryItems"
    ADD CONSTRAINT "FK_acfcaa8bcf9c198372a9b90207b" FOREIGN KEY ("episodeId") REFERENCES public.episodes(id) ON DELETE CASCADE;


--
-- Name: podcasts_categories_categories FK_b4e928000238b50d848c0f36842; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.podcasts_categories_categories
    ADD CONSTRAINT "FK_b4e928000238b50d848c0f36842" FOREIGN KEY ("podcastsId") REFERENCES public.podcasts(id) ON DELETE CASCADE;


--
-- Name: userQueueItems FK_b651ccc2eec2cb1936244ea742a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."userQueueItems"
    ADD CONSTRAINT "FK_b651ccc2eec2cb1936244ea742a" FOREIGN KEY ("ownerId") REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: bitpayInvoices FK_c4ca0576618c47e527dad9f4ef2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."bitpayInvoices"
    ADD CONSTRAINT "FK_c4ca0576618c47e527dad9f4ef2" FOREIGN KEY ("ownerId") REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: categories FK_c9594c262e6781893a1068d91be; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT "FK_c9594c262e6781893a1068d91be" FOREIGN KEY ("categoryId") REFERENCES public.categories(id) ON DELETE CASCADE;


--
-- Name: feedUrls FK_ca594e30e640feb8ec4015dfa46; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."feedUrls"
    ADD CONSTRAINT "FK_ca594e30e640feb8ec4015dfa46" FOREIGN KEY ("podcastId") REFERENCES public.podcasts(id) ON DELETE CASCADE;


--
-- Name: podcasts_categories_categories FK_cfa3de60daca1fdd5a10e68faae; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.podcasts_categories_categories
    ADD CONSTRAINT "FK_cfa3de60daca1fdd5a10e68faae" FOREIGN KEY ("categoriesId") REFERENCES public.categories(id) ON DELETE CASCADE;


--
-- Name: userHistoryItems FK_e43c5eb439402e4f06226736619; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."userHistoryItems"
    ADD CONSTRAINT "FK_e43c5eb439402e4f06226736619" FOREIGN KEY ("ownerId") REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: userHistoryItems FK_e87e78a873e585bbd2f544ee2ae; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."userHistoryItems"
    ADD CONSTRAINT "FK_e87e78a873e585bbd2f544ee2ae" FOREIGN KEY ("mediaRefId") REFERENCES public."mediaRefs"(id) ON DELETE CASCADE;


--
-- Name: media_refs_authors_authors FK_f380a166d117b8c864caf5d8329; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.media_refs_authors_authors
    ADD CONSTRAINT "FK_f380a166d117b8c864caf5d8329" FOREIGN KEY ("mediaRefsId") REFERENCES public."mediaRefs"(id) ON DELETE CASCADE;


--
-- Name: playlists_media_refs_media_refs FK_f85c01764ccf3287ddaeb44fc6b; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlists_media_refs_media_refs
    ADD CONSTRAINT "FK_f85c01764ccf3287ddaeb44fc6b" FOREIGN KEY ("mediaRefsId") REFERENCES public."mediaRefs"(id) ON DELETE CASCADE;


--
-- Name: playlists_media_refs_media_refs FK_fc0a928532ac8066e06c3dd1256; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlists_media_refs_media_refs
    ADD CONSTRAINT "FK_fc0a928532ac8066e06c3dd1256" FOREIGN KEY ("playlistsId") REFERENCES public.playlists(id) ON DELETE CASCADE;


--
-- Name: userNowPlayingItems FK_fde0d2aff935c3301266e38a110; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."userNowPlayingItems"
    ADD CONSTRAINT "FK_fde0d2aff935c3301266e38a110" FOREIGN KEY ("mediaRefId") REFERENCES public."mediaRefs"(id) ON DELETE CASCADE;


--
-- Name: podcasts_authors_authors FK_ff3fe42ceba07c5d88125a0d781; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.podcasts_authors_authors
    ADD CONSTRAINT "FK_ff3fe42ceba07c5d88125a0d781" FOREIGN KEY ("podcastsId") REFERENCES public.podcasts(id) ON DELETE CASCADE;


--
-- Name: liveItems FK_liveItems_episode; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."liveItems"
    ADD CONSTRAINT "FK_liveItems_episode" FOREIGN KEY ("episodeId") REFERENCES public.episodes(id);


--
-- Name: auth_group_permissions auth_group_permissio_permission_id_84c5c92e_fk_auth_perm; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissio_permission_id_84c5c92e_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_group_permissions auth_group_permissions_group_id_b120cbf9_fk_auth_group_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_b120cbf9_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_permission auth_permission_content_type_id_2f476e4b_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_2f476e4b_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_groups auth_user_groups_group_id_97559544_fk_auth_group_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_group_id_97559544_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_groups auth_user_groups_user_id_6a12ed8b_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_user_id_6a12ed8b_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_user_permissions auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_user_permissions auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_admin_log django_admin_log_content_type_id_c4bce8eb_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_content_type_id_c4bce8eb_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_admin_log django_admin_log_user_id_c564eba6_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_user_id_c564eba6_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_mfa_u2fkey django_mfa_u2fkey_user_id_2d00d3c1_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_mfa_u2fkey
    ADD CONSTRAINT django_mfa_u2fkey_user_id_2d00d3c1_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_mfa_userotp django_mfa_userotp_user_id_1535e3f9_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_mfa_userotp
    ADD CONSTRAINT django_mfa_userotp_user_id_1535e3f9_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_mfa_userrecoverycodes django_mfa_userrecov_user_id_2cb8601a_fk_django_mf; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_mfa_userrecoverycodes
    ADD CONSTRAINT django_mfa_userrecov_user_id_2cb8601a_fk_django_mf FOREIGN KEY (user_id) REFERENCES public.django_mfa_userotp(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: fcmDevices fcmDevices_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."fcmDevices"
    ADD CONSTRAINT "fcmDevices_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_podcastId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT "notifications_podcastId_fkey" FOREIGN KEY ("podcastId") REFERENCES public.podcasts(id);


--
-- Name: notifications notifications_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT "notifications_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

