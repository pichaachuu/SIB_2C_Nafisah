--
-- PostgreSQL database dump
--

\restrict uEX69MBTnj6trbCkj4KV3OCSRzivDUqYNPxuaWtJAcSWuq9MUiEUtC6mFHEUvl1

-- Dumped from database version 15.14
-- Dumped by pg_dump version 15.14

-- Started on 2025-11-13 23:30:35

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
-- TOC entry 226 (class 1255 OID 26117)
-- Name: get_department_summary(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_department_summary() RETURNS TABLE(department text, employee_count bigint, avg_salary numeric, total_budget numeric)
    LANGUAGE sql
    AS $$
    SELECT
        department,
        COUNT(*) AS employee_count,
        ROUND(AVG(salary)::numeric, 2) AS avg_salary,
        SUM(salary)::numeric AS total_budget
    FROM employees
    GROUP BY department
    ORDER BY department;
$$;


ALTER FUNCTION public.get_department_summary() OWNER TO postgres;

--
-- TOC entry 227 (class 1255 OID 26119)
-- Name: get_employees_by_salary_range(numeric, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_employees_by_salary_range(min_salary numeric, max_salary numeric) RETURNS TABLE(id integer, full_name text, department text, "position" text, salary numeric)
    LANGUAGE sql
    AS $$
    SELECT
        id,
        CONCAT(first_name, ' ', last_name) AS full_name,
        department,
        position,
        salary
    FROM employees
    WHERE salary BETWEEN min_salary AND max_salary
    ORDER BY salary DESC, id;
$$;


ALTER FUNCTION public.get_employees_by_salary_range(min_salary numeric, max_salary numeric) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 218 (class 1259 OID 26062)
-- Name: employees; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employees (
    id integer NOT NULL,
    first_name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    email character varying(50) NOT NULL,
    department character varying(50),
    "position" character varying(50),
    salary numeric(10,2),
    hire_date date,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.employees OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 26072)
-- Name: projects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.projects (
    id integer NOT NULL,
    project_name character varying(100) NOT NULL,
    department character varying(50),
    budget numeric(12,2),
    start_date date,
    end_date date,
    status character varying(20) DEFAULT 'Active'::character varying
);


ALTER TABLE public.projects OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 26088)
-- Name: dashboard_summary; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.dashboard_summary AS
 SELECT ( SELECT count(*) AS count
           FROM public.employees) AS total_employees,
    ( SELECT count(*) AS count
           FROM public.projects) AS total_projects,
    ( SELECT count(DISTINCT employees.department) AS count
           FROM public.employees) AS total_departments,
    ( SELECT round(avg(employees.salary), 2) AS round
           FROM public.employees) AS company_avg_salary,
    ( SELECT max(employees.salary) AS max
           FROM public.employees) AS highest_salary,
    ( SELECT min(employees.salary) AS min
           FROM public.employees) AS lowest_salary,
    ( SELECT sum(projects.budget) AS sum
           FROM public.projects) AS total_project_budget,
    ( SELECT count(*) AS count
           FROM public.projects
          WHERE ((projects.status)::text = 'Active'::text)) AS active_projects,
    ( SELECT count(*) AS count
           FROM public.projects
          WHERE ((projects.status)::text = 'Planning'::text)) AS planning_projects,
    ( SELECT round(avg(EXTRACT(year FROM age((CURRENT_DATE)::timestamp with time zone, (employees.hire_date)::timestamp with time zone))), 1) AS round
           FROM public.employees) AS avg_years_service
  WITH NO DATA;


ALTER TABLE public.dashboard_summary OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 26084)
-- Name: department_stats; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.department_stats AS
 SELECT employees.department,
    count(*) AS total_employees,
    round(avg(employees.salary), 2) AS avg_salary,
    min(employees.salary) AS min_salary,
    max(employees.salary) AS max_salary,
    sum(employees.salary) AS total_salary_budget
   FROM public.employees
  GROUP BY employees.department
  ORDER BY (count(*)) DESC;


ALTER TABLE public.department_stats OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 16653)
-- Name: departments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.departments (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    location character varying(100)
);


ALTER TABLE public.departments OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 16652)
-- Name: departments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.departments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.departments_id_seq OWNER TO postgres;

--
-- TOC entry 3385 (class 0 OID 0)
-- Dependencies: 214
-- Name: departments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.departments_id_seq OWNED BY public.departments.id;


--
-- TOC entry 221 (class 1259 OID 26079)
-- Name: employee_summary; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.employee_summary AS
 SELECT employees.id,
    concat(employees.first_name, ' ', employees.last_name) AS full_name,
    employees.department,
    employees."position",
    employees.salary,
    EXTRACT(year FROM age((CURRENT_DATE)::timestamp with time zone, (employees.hire_date)::timestamp with time zone)) AS years_of_service,
        CASE
            WHEN (EXTRACT(year FROM age((CURRENT_DATE)::timestamp with time zone, (employees.hire_date)::timestamp with time zone)) >= (3)::numeric) THEN 'Senior'::text
            WHEN (EXTRACT(year FROM age((CURRENT_DATE)::timestamp with time zone, (employees.hire_date)::timestamp with time zone)) >= (1)::numeric) THEN 'Intermediate'::text
            ELSE 'Junior'::text
        END AS experience_level
   FROM public.employees
  ORDER BY employees.department, employees.salary DESC;


ALTER TABLE public.employee_summary OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 26061)
-- Name: employees_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.employees_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.employees_id_seq OWNER TO postgres;

--
-- TOC entry 3386 (class 0 OID 0)
-- Dependencies: 217
-- Name: employees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.employees_id_seq OWNED BY public.employees.id;


--
-- TOC entry 216 (class 1259 OID 16683)
-- Name: employess_projects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employess_projects (
    employee_id integer NOT NULL,
    project_id integer NOT NULL,
    hours_worked numeric(5,2),
    assignment_date date DEFAULT CURRENT_DATE
);


ALTER TABLE public.employess_projects OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 26071)
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.projects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.projects_id_seq OWNER TO postgres;

--
-- TOC entry 3387 (class 0 OID 0)
-- Dependencies: 219
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.projects_id_seq OWNED BY public.projects.id;


--
-- TOC entry 224 (class 1259 OID 26105)
-- Name: ringkasan_karyawan; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.ringkasan_karyawan AS
 SELECT count(*) AS total_employees,
    sum(employees.salary) AS total_salary_per_month,
    round(avg(EXTRACT(year FROM age((CURRENT_DATE)::timestamp with time zone, (employees.hire_date)::timestamp with time zone))), 1) AS avg_years_service
   FROM public.employees;


ALTER TABLE public.ringkasan_karyawan OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 26109)
-- Name: tenure_stats; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.tenure_stats AS
 SELECT
        CASE
            WHEN (EXTRACT(year FROM age((CURRENT_DATE)::timestamp with time zone, (employees.hire_date)::timestamp with time zone)) >= (3)::numeric) THEN 'Senior'::text
            WHEN (EXTRACT(year FROM age((CURRENT_DATE)::timestamp with time zone, (employees.hire_date)::timestamp with time zone)) >= (1)::numeric) THEN 'Intermediate'::text
            ELSE 'Junior'::text
        END AS level,
    count(*) AS count_employees
   FROM public.employees
  GROUP BY
        CASE
            WHEN (EXTRACT(year FROM age((CURRENT_DATE)::timestamp with time zone, (employees.hire_date)::timestamp with time zone)) >= (3)::numeric) THEN 'Senior'::text
            WHEN (EXTRACT(year FROM age((CURRENT_DATE)::timestamp with time zone, (employees.hire_date)::timestamp with time zone)) >= (1)::numeric) THEN 'Intermediate'::text
            ELSE 'Junior'::text
        END;


ALTER TABLE public.tenure_stats OWNER TO postgres;

--
-- TOC entry 3209 (class 2604 OID 16656)
-- Name: departments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departments ALTER COLUMN id SET DEFAULT nextval('public.departments_id_seq'::regclass);


--
-- TOC entry 3211 (class 2604 OID 26065)
-- Name: employees id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees ALTER COLUMN id SET DEFAULT nextval('public.employees_id_seq'::regclass);


--
-- TOC entry 3213 (class 2604 OID 26075)
-- Name: projects id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects ALTER COLUMN id SET DEFAULT nextval('public.projects_id_seq'::regclass);


--
-- TOC entry 3373 (class 0 OID 16653)
-- Dependencies: 215
-- Data for Name: departments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.departments (id, name, location) FROM stdin;
1	IT	Jakarta
2	HR	Bandung
3	Finance	Surabaya
4	Marketing	Medan
5	Operation	Yogyakarta
\.


--
-- TOC entry 3376 (class 0 OID 26062)
-- Dependencies: 218
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employees (id, first_name, last_name, email, department, "position", salary, hire_date, created_at) FROM stdin;
1	Ahmad	Hidayat	ahmad.hidayat@company.com	IT	Software Engineer	8500000.00	2022-01-15	2025-11-07 08:10:18.929609
2	Siti	Rahayu	siti.rahayu@company.com	HR	HR Manager	9500000.00	2021-03-20	2025-11-07 08:10:18.929609
3	Budi	Santoso	budi.santoso@company.com	Finance	Accountant	7500000.00	2022-06-10	2025-11-07 08:10:18.929609
4	Dewi	Anggraini	dewi.anggraini@company.com	Marketing	Marketing \nSpecialist	7000000.00	2023-02-01	2025-11-07 08:10:18.929609
5	Rizki	Pratama	rizki.pratama@company.com	IT	System Administrator	8000000.00	2021-11-05	2025-11-07 08:10:18.929609
6	Maya	Sari	maya.sari@company.com	Finance	Financial Analyst	8200000.00	2022-08-15	2025-11-07 08:10:18.929609
7	Joko	Widodo	joko.widodo@company.com	Operations	Operations \nManager	11000000.00	2020-05-12	2025-11-07 08:10:18.929609
8	Linda	Permata	linda.permata@company.com	Marketing	Digital \nMarketer	6800000.00	2023-01-30	2025-11-07 08:10:18.929609
9	Fajar	Nugroho	fajar.nugroho@company.com	IT	Web Developer	7800000.00	2022-09-22	2025-11-07 08:10:18.929609
10	Rina	Wulandari	rina.wulandari@company.com	HR	Recruitment \nSpecialist	6500000.00	2023-03-10	2025-11-07 08:10:18.929609
11	Hendra	Kurniawan	hendra.kurniawan@company.com	Finance	Tax \nOfficer	7200000.00	2022-04-18	2025-11-07 08:10:18.929609
12	Dian	Puspita	dian.puspita@company.com	IT	Database Administrator	9000000.00	2021-07-25	2025-11-07 08:10:18.929609
13	Eko	Supriyanto	eko.supriyanto@company.com	Operations	Logistics \nCoordinator	6000000.00	2023-05-05	2025-11-07 08:10:18.929609
14	Fitri	Handayani	fitri.handayani@company.com	Marketing	Content \nCreator	5800000.00	2023-04-12	2025-11-07 08:10:18.929609
15	Gita	Maharani	gita.maharani@company.com	HR	Training Officer	6200000.00	2022-12-01	2025-11-07 08:10:18.929609
16	Irfan	Setiawan	irfan.setiawan@company.com	IT	Network Engineer	8300000.00	2021-09-14	2025-11-07 08:10:18.929609
17	Kartika	Dewi	kartika.dewi@company.com	Finance	Auditor	7700000.00	2022-03-08	2025-11-07 08:10:18.929609
18	Lukman	Hakim	lukman.hakim@company.com	Operations	Warehouse \nManager	7300000.00	2021-12-20	2025-11-07 08:10:18.929609
21	Nafisah	Aliyah	nafisahaliyah01@gmail.com	IT	Leader	15000000.00	2025-11-07	2025-11-07 09:57:19.667354
20	Oscar	Fernando	oscar.fernando@company.com	IT	Mobile Developer	8000000.00	2022-11-11	2025-11-07 08:10:18.929609
\.


--
-- TOC entry 3374 (class 0 OID 16683)
-- Dependencies: 216
-- Data for Name: employess_projects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employess_projects (employee_id, project_id, hours_worked, assignment_date) FROM stdin;
1	1	120.50	2023-01-15
1	6	80.00	2023-02-01
2	1	95.50	2023-01-20
2	2	150.00	2023-02-15
3	3	200.00	2023-03-01
4	3	180.50	2023-03-05
5	4	220.00	2023-04-01
6	4	190.50	2023-04-05
7	5	175.00	2023-05-01
8	5	160.50	2023-05-10
9	2	140.00	2023-06-01
9	6	90.50	2023-06-15
10	4	210.00	2023-07-01
11	7	100.00	2023-07-15
12	8	180.00	2023-08-01
\.


--
-- TOC entry 3378 (class 0 OID 26072)
-- Dependencies: 220
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.projects (id, project_name, department, budget, start_date, end_date, status) FROM stdin;
1	Website Redesign	IT	150000000.00	2024-01-01	2024-06-30	Active
2	Employee Training Program	HR	75000000.00	2024-02-01	2024-05-31	Active
3	Financial System Upgrade	Finance	200000000.00	2024-03-01	2024-08-31	Planning
4	Digital Marketing Campaign	Marketing	120000000.00	2024-01-15	2024-04-30	Active
5	Warehouse Optimization	Operations	90000000.00	2024-02-20	2024-07-15	Active
6	Mobile App Development	IT	180000000.00	2024-03-10	2024-09-30	Planning
7	Recruitment Drive 2024	HR	50000000.00	2024-04-01	2024-06-30	Active
8	Customer Satisfaction Survey	Marketing	40000000.00	2024-03-15	2024-05-31	Active
9	Network Infrastructure	IT	220000000.00	2024-05-01	2024-12-31	Planning
10	Annual Audit Preparation	Finance	60000000.00	2024-04-15	2024-07-31	Active
\.


--
-- TOC entry 3388 (class 0 OID 0)
-- Dependencies: 214
-- Name: departments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.departments_id_seq', 5, true);


--
-- TOC entry 3389 (class 0 OID 0)
-- Dependencies: 217
-- Name: employees_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.employees_id_seq', 21, true);


--
-- TOC entry 3390 (class 0 OID 0)
-- Dependencies: 219
-- Name: projects_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.projects_id_seq', 10, true);


--
-- TOC entry 3216 (class 2606 OID 16658)
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (id);


--
-- TOC entry 3220 (class 2606 OID 26070)
-- Name: employees employees_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_email_key UNIQUE (email);


--
-- TOC entry 3222 (class 2606 OID 26068)
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (id);


--
-- TOC entry 3218 (class 2606 OID 16688)
-- Name: employess_projects employess_projects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employess_projects
    ADD CONSTRAINT employess_projects_pkey PRIMARY KEY (employee_id, project_id);


--
-- TOC entry 3224 (class 2606 OID 26078)
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- TOC entry 3379 (class 0 OID 26088)
-- Dependencies: 223 3381
-- Name: dashboard_summary; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.dashboard_summary;


-- Completed on 2025-11-13 23:30:36

--
-- PostgreSQL database dump complete
--

\unrestrict uEX69MBTnj6trbCkj4KV3OCSRzivDUqYNPxuaWtJAcSWuq9MUiEUtC6mFHEUvl1

